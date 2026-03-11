import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/response.ts";
import { createSupabaseClient, requireAuth } from "../_shared/auth.ts";
import { requireFields } from "../_shared/validation.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action");

    if (req.method === "POST" && action === "register") {
      return await handleRegister(req);
    }

    return errorResponse("bad_request", "Unknown action or method", 400);
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

async function handleRegister(req: Request): Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  await requireAuth(supabase);

  const body = await req.json();
  requireFields(body, ["instagram_username"]);

  const username = body.instagram_username.replace(/^@/, "").trim().toLowerCase();

  // 1. influencers에 이미 존재하는지 확인
  const { data: existing } = await supabase
    .from("influencers")
    .select("id")
    .eq("username", username)
    .single();

  if (existing) {
    return errorResponse("already_registered", "Already registered", 409);
  }

  // 2. influencer_suggestions INSERT (UNIQUE 제약으로 동시성 제어)
  const { error: insertError } = await supabase
    .from("influencer_suggestions")
    .insert({ instagram_username: username, status: "processing" });

  if (insertError) {
    // UNIQUE 위반 → 이미 접수된 요청
    const { data: suggestion } = await supabase
      .from("influencer_suggestions")
      .select("status")
      .eq("instagram_username", username)
      .single();

    if (suggestion?.status === "completed") {
      return errorResponse("already_registered", "Already registered", 409);
    }
    // processing or failed → 이미 접수됨
    return jsonResponse({ status: "processing" }, 200);
  }

  // 3. 즉시 200 반환 + 백그라운드에서 Apify 검증 진행
  verifyInBackground(username);

  return jsonResponse({ status: "processing" }, 200);
}

/** 백그라운드에서 Apify API 호출 → 검증 → influencers INSERT */
function verifyInBackground(username: string): void {
  // service role 클라이언트 (RLS bypass)
  const serviceSupabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
  );

  const task = async () => {
    try {
      // Apify Instagram Profile Scraper 호출
      const apifyToken = Deno.env.get("APIFY_TOKEN");
      const apifyResponse = await fetch(
        `https://api.apify.com/v2/acts/apify~instagram-profile-scraper/run-sync-get-dataset-items?token=${apifyToken}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ usernames: [username] }),
        }
      );

      if (!apifyResponse.ok) {
        await markFailed(serviceSupabase, username, "apify_api_error");
        return;
      }

      const profiles = await apifyResponse.json();

      // 계정 없음
      if (!profiles || profiles.length === 0) {
        await markFailed(serviceSupabase, username, "account_not_found");
        return;
      }

      const profile = profiles[0];

      // 비공개 계정
      if (profile.private) {
        await markFailed(serviceSupabase, username, "private_account");
        return;
      }

      // 팔로워 1만 미만
      if ((profile.followersCount ?? 0) < 10000) {
        await markFailed(serviceSupabase, username, "insufficient_followers");
        return;
      }

      // external_url 없음 (공구 링크 페이지 필수)
      if (!profile.externalUrl) {
        await markFailed(serviceSupabase, username, "no_external_url");
        return;
      }

      // 검증 통과 → influencers INSERT
      const { error: influencerError } = await serviceSupabase
        .from("influencers")
        .insert({
          id: `inf_${crypto.randomUUID()}`,
          username: profile.username ?? username,
          full_name: profile.fullName ?? null,
          biography: profile.biography ?? null,
          profile_pic_url: profile.profilePicUrl ?? null,
          followers_count: profile.followersCount ?? 0,
          external_url: profile.externalUrl ?? null,
          external_url_title: profile.externalUrlTitle ?? null,
          last_synced_at: new Date().toISOString(),
        });

      if (influencerError) {
        await markFailed(serviceSupabase, username, "insert_failed");
        return;
      }

      // suggestions → completed
      await serviceSupabase
        .from("influencer_suggestions")
        .update({ status: "completed" })
        .eq("instagram_username", username);
    } catch {
      await markFailed(serviceSupabase, username, "unexpected_error");
    }
  };

  task();
}

async function markFailed(
  supabase: ReturnType<typeof createClient>,
  username: string,
  reason: string
): Promise<void> {
  await supabase
    .from("influencer_suggestions")
    .update({ status: "failed", error_reason: reason })
    .eq("instagram_username", username);
}
