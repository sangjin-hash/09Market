import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface AuthUser {
  id: string;
}

export function createSupabaseClient(authHeader: string): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } }
  );
}

/** 인증 필수: 실패 시 throw */
export async function requireAuth(
  supabase: SupabaseClient
): Promise<AuthUser> {
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();
  if (error || !user) {
    throw {
      error: "unauthorized",
      message: "Invalid or expired token",
      status: 401,
    };
  }
  return { id: user.id };
}

/** 인증 선택: 비로그인 시 null 반환 */
export async function optionalAuth(
  supabase: SupabaseClient
): Promise<AuthUser | null> {
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();
  if (error || !user) return null;
  return { id: user.id };
}
