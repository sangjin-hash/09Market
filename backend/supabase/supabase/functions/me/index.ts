import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * GET /me
 *
 * Authorization 헤더의 JWT로 사용자를 식별하고 프로필을 조회한다.
 *
 * Response:
 *   200: { id, nickname, profile_url, provider, ... }  — 소셜 로그인 유저
 *   204: (empty body)                                   — 익명 유저 (프로필 없음)
 *   401: 토큰 없음 또는 유효하지 않음
 *   405: GET 이외의 메서드
 *   500: 서버 에러
 */
Deno.serve(async (req) => {
  if (req.method !== "GET") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonResponse({ error: "Missing authorization header" }, 401);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } }
  );

  // JWT 검증 및 사용자 식별
  const {
    data: { user: authUser },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !authUser) {
    return jsonResponse({ error: "Invalid or expired token" }, 401);
  }

  // 익명 유저는 users 테이블에 row가 없으므로 204 No Content
  if (authUser.is_anonymous) {
    return new Response(null, { status: 204 });
  }

  // 소셜 유저: users 테이블에서 프로필 조회
  const { data, error } = await supabase
    .from("users")
    .select("id, nickname, profile_url, provider, created_at")
    .eq("id", authUser.id)
    .single();

  if (error) {
    // 소셜 유저인데 row가 없는 경우 (트리거 실패 등 비정상)
    if (error.code === "PGRST116") {
      return new Response(null, { status: 204 });
    }
    return jsonResponse({ error: error.message }, 500);
  }

  return jsonResponse(data, 200);
});

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
