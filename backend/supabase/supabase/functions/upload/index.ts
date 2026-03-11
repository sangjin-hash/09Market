import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/response.ts";
import { createServiceClient, validateFile, uploadToTemp } from "../_shared/storage.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return errorResponse("method_not_allowed", "Method not allowed", 405);
    }

    // Authorization 헤더에서 Bearer 토큰 추출 → service client로 검증
    const authHeader = req.headers.get("Authorization") ?? "";
    const token = authHeader.replace("Bearer ", "");
    if (!token) {
      return errorResponse("unauthorized", "Missing authorization token", 401);
    }

    const serviceClient = createServiceClient();
    const { data: { user }, error: authError } = await serviceClient.auth.getUser(token);
    if (authError || !user) {
      return errorResponse("unauthorized", "Invalid or expired token", 401);
    }

    // FormData 파싱
    const formData = await req.formData();
    const file = formData.get("file");

    if (!file || !(file instanceof File)) {
      return errorResponse(
        "missing_required_field",
        "'file' is required",
        400
      );
    }

    // 파일 검증
    const validation = validateFile(file);
    if (!validation.valid) {
      return errorResponse(validation.error, validation.message, 400);
    }

    // temp/ 에 업로드
    const url = await uploadToTemp(file);

    return jsonResponse({ url }, 200);
  } catch (e) {
    if (e && typeof e === "object" && "status" in e) {
      return errorResponse(
        (e as Record<string, unknown>).error as string,
        (e as Record<string, unknown>).message as string,
        (e as Record<string, unknown>).status as number
      );
    }
    return errorResponse("internal_error", String(e), 500);
  }
});
