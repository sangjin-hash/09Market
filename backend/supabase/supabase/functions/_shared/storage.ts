import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const BUCKET = "media";
const TEMP_PREFIX = "temp/";
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/heic", "image/webp"];

const MIME_TO_EXT: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/heic": "heic",
  "image/webp": "webp",
};

/** service_role 권한의 Supabase 클라이언트 (Storage 조작용) */
export function createServiceClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
  );
}

/** 파일 검증: MIME 타입 + 크기 */
export function validateFile(
  file: File
): { valid: true } | { valid: false; error: string; message: string } {
  if (!ALLOWED_TYPES.includes(file.type)) {
    return {
      valid: false,
      error: "invalid_file_type",
      message: `Allowed types: ${ALLOWED_TYPES.join(", ")}`,
    };
  }
  if (file.size > MAX_FILE_SIZE) {
    return {
      valid: false,
      error: "file_too_large",
      message: `Max file size: ${MAX_FILE_SIZE / 1024 / 1024}MB`,
    };
  }
  return { valid: true };
}

/** temp/ 에 파일 업로드 후 Public URL 반환 */
export async function uploadToTemp(file: File): Promise<string> {
  const serviceClient = createServiceClient();
  const ext = MIME_TO_EXT[file.type] ?? "jpg";
  const uuid = crypto.randomUUID();
  const path = `${TEMP_PREFIX}${uuid}.${ext}`;

  const buffer = await file.arrayBuffer();

  const { error } = await serviceClient.storage
    .from(BUCKET)
    .upload(path, buffer, {
      contentType: file.type,
      upsert: false,
    });

  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }

  return getPublicUrl(path);
}

/** Storage 파일 이동 (Supabase move API) */
export async function moveFile(
  fromPath: string,
  toPath: string
): Promise<string> {
  const serviceClient = createServiceClient();

  const { error } = await serviceClient.storage
    .from(BUCKET)
    .move(fromPath, toPath);

  if (error) {
    throw new Error(`Storage move failed: ${error.message}`);
  }

  return getPublicUrl(toPath);
}

/** URL에서 Storage 경로 추출 */
export function extractStoragePath(url: string): string | null {
  const marker = `/storage/v1/object/public/${BUCKET}/`;
  const idx = url.indexOf(marker);
  if (idx === -1) return null;
  return url.substring(idx + marker.length);
}

/** temp/ URL인지 확인 */
export function isTempUrl(url: string): boolean {
  const path = extractStoragePath(url);
  return path !== null && path.startsWith(TEMP_PREFIX);
}

/** Storage 경로 → Public URL */
export function getPublicUrl(path: string): string {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  return `${supabaseUrl}/storage/v1/object/public/${BUCKET}/${path}`;
}

/** URL에서 파일명(uuid.ext) 추출 */
export function extractFileName(url: string): string | null {
  const path = extractStoragePath(url);
  if (!path) return null;
  const parts = path.split("/");
  return parts[parts.length - 1] ?? null;
}

/** 외부 URL에서 이미지를 다운로드하여 지정 경로에 업로드 (re-hosting) */
export async function rehostImage(
  sourceUrl: string,
  destPath: string
): Promise<string> {
  const serviceClient = createServiceClient();

  const response = await fetch(sourceUrl);
  if (!response.ok) {
    throw new Error(`Failed to download image: ${response.status}`);
  }

  const buffer = await response.arrayBuffer();
  const contentType = response.headers.get("content-type") ?? "image/jpeg";

  const { error } = await serviceClient.storage
    .from(BUCKET)
    .upload(destPath, buffer, {
      contentType,
      upsert: true,
    });

  if (error) {
    throw new Error(`Storage rehost upload failed: ${error.message}`);
  }

  return getPublicUrl(destPath);
}
