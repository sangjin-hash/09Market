import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/response.ts";
import { createSupabaseClient, requireAuth } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const supabase = createSupabaseClient(authHeader);

    switch (req.method) {
      case "GET":
        return await handleGet(supabase);
      case "PUT":
        return await handlePut(req, supabase);
      default:
        return errorResponse("method_not_allowed", "Method not allowed", 405);
    }
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

// ─── GET /me ───

async function handleGet(supabase: Parameters<typeof requireAuth>[0]): Promise<Response> {
  const {
    data: { user: authUser },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !authUser) {
    return errorResponse("unauthorized", "Invalid or expired token", 401);
  }

  // 익명 유저는 users 테이블에 row가 없으므로 204
  if (authUser.is_anonymous) {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  const { data, error } = await supabase
    .from("users")
    .select("id, nickname, profile_url, provider, created_at")
    .eq("id", authUser.id)
    .single();

  if (error) {
    if (error.code === "PGRST116") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }
    return errorResponse("internal_error", error.message, 500);
  }

  return jsonResponse(data, 200);
}

// ─── PUT /me ───

async function handlePut(req: Request, supabase: Parameters<typeof requireAuth>[0]): Promise<Response> {
  const authUser = await requireAuth(supabase);

  const body = await req.json();
  const updates: Record<string, unknown> = {};

  if (body.nickname !== undefined) updates.nickname = body.nickname;
  if (body.profile_url !== undefined) updates.profile_url = body.profile_url;

  if (Object.keys(updates).length === 0) {
    return errorResponse("no_fields_to_update", "nickname or profile_url required", 400);
  }

  const { data, error } = await supabase
    .from("users")
    .update(updates)
    .eq("id", authUser.id)
    .select()
    .single();

  if (error) {
    return errorResponse("update_error", error.message, 500);
  }

  return jsonResponse(data, 200);
}
