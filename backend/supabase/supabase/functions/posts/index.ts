import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/response.ts";
import { createSupabaseClient, requireAuth } from "../_shared/auth.ts";
import { requireFields, parseIntParam } from "../_shared/validation.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action");

    switch (true) {
      case req.method === "GET" && action === "list":
        return await handleList(req, url);
      case req.method === "GET" && action === "top10":
        return await handleTop10(req, url);
      case req.method === "GET" && action === "schedule":
        return await handleSchedule(req, url);
      case req.method === "POST" && action === "create":
        return await handleCreate(req);
      case req.method === "PUT" && action === "update":
        return await handleUpdate(req);
      case req.method === "DELETE" && action === "delete":
        return await handleDelete(req);
      default:
        return errorResponse("bad_request", "Unknown action or method", 400);
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

// ─── GET /posts?action=list ───

async function handleList(req: Request, url: URL): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  const authUser = await requireAuth(supabase);

  const page = parseIntParam(url, "page", 1);
  const limit = Math.min(parseIntParam(url, "limit", 20), 50);
  const search = url.searchParams.get("search");
  const category = url.searchParams.get("category");
  const dateFrom = url.searchParams.get("date_from");
  const dateTo = url.searchParams.get("date_to");
  const offset = (page - 1) * limit;

  let query = supabase
    .from("posts")
    .select(
      "id, product_name, price, category, display_url, group_buying_start, group_buying_end, group_buying_url, likes_count, posted_at, influencers(id, username, full_name, profile_pic_url, external_url)",
      { count: "exact" }
    )
    .not("group_buying_start", "is", null)
    .not("group_buying_end", "is", null);

  // 날짜 필터 (명시적으로 제공된 경우만)
  if (dateFrom && dateTo) {
    query = query
      .lte("group_buying_start", dateTo)
      .gte("group_buying_end", dateFrom);
  }

  // 카테고리 필터
  if (category) {
    query = query.eq("category", category);
  }

  // 검색
  if (search) {
    const { data: matchedInfluencers } = await supabase
      .from("influencers")
      .select("id")
      .or(`username.ilike.%${search}%,full_name.ilike.%${search}%`);

    const ids = (matchedInfluencers ?? []).map((i: { id: string }) => i.id);

    if (ids.length > 0) {
      query = query.or(
        `product_name.ilike.%${search}%,influencer_id.in.(${ids.join(",")})`
      );
    } else {
      query = query.ilike("product_name", `%${search}%`);
    }
  }

  // 날짜 필터가 있으면 DB 정렬 + 페이지네이션, 없으면 전체 조회 후 앱 정렬
  if (dateFrom && dateTo) {
    query = query
      .order("group_buying_start", { ascending: false })
      .range(offset, offset + limit - 1);
  }

  const { data, error, count } = await query;

  if (error) {
    return errorResponse("query_error", error.message, 500);
  }

  let posts = data ?? [];

  // 기본 정렬: 진행중+예정 → 랜덤 셔플 / 마감 → 종료일 역순
  if (!dateFrom || !dateTo) {
    const now = new Date().toISOString();
    const active: typeof posts = [];
    const expired: typeof posts = [];

    for (const p of posts) {
      if ((p.group_buying_end as string) >= now) {
        active.push(p);
      } else {
        expired.push(p);
      }
    }

    // 진행중/예정: 일별 시드 기반 셔플 (페이지네이션 일관성 유지)
    shuffleWithDailySeed(active);

    // 마감: 종료일 역순
    expired.sort((a, b) =>
      (b.group_buying_end as string).localeCompare(a.group_buying_end as string)
    );

    const sorted = [...active, ...expired];
    posts = sorted.slice(offset, offset + limit);
  }

  // is_liked 처리
  let likedSet: Set<string> = new Set();

  if (posts.length > 0) {
    const postIds = posts.map((p: { id: string }) => p.id);
    const { data: likes } = await supabase
      .from("likes")
      .select("post_id")
      .eq("user_id", authUser.id)
      .in("post_id", postIds);

    likedSet = new Set((likes ?? []).map((l: { post_id: string }) => l.post_id));
  }

  const result = posts.map((post: Record<string, unknown>) => ({
    ...post,
    display_url: post.display_url ?? null,
    influencer: post.influencers,
    influencers: undefined,
    is_liked: likedSet.has(post.id as string),
  }));

  return jsonResponse({ data: result, total: count, page }, 200);
}

// ─── 일별 시드 기반 셔플 (KST) ───

function shuffleWithDailySeed(arr: Record<string, unknown>[]): void {
  const kst = new Date(Date.now() + 9 * 60 * 60 * 1000);
  let seed = kst.getFullYear() * 10000 + (kst.getMonth() + 1) * 100 + kst.getDate();

  const random = (): number => {
    seed = (seed + 0x6D2B79F5) | 0;
    let r = Math.imul(seed ^ (seed >>> 15), seed | 1);
    r ^= r + Math.imul(r ^ (r >>> 7), r | 61);
    return ((r ^ (r >>> 14)) >>> 0) / 4294967296;
  };

  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
}

// ─── GET /posts?action=top10 ───

async function handleTop10(req: Request, _url: URL): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  const authUser = await requireAuth(supabase);

  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const { data, error } = await supabase
    .from("posts")
    .select(
      "id, product_name, price, category, display_url, group_buying_start, group_buying_end, group_buying_url, likes_count, posted_at, influencers(id, username, full_name, profile_pic_url, external_url)"
    )
    .not("group_buying_start", "is", null)
    .not("group_buying_end", "is", null)
    .lte("group_buying_start", now.toISOString())
    .gte("group_buying_end", weekAgo)
    .order("likes_count", { ascending: false })
    .limit(10);

  if (error) {
    return errorResponse("query_error", error.message, 500);
  }

  const posts = data ?? [];
  let likedSet: Set<string> = new Set();

  if (posts.length > 0) {
    const postIds = posts.map((p: { id: string }) => p.id);
    const { data: likes } = await supabase
      .from("likes")
      .select("post_id")
      .eq("user_id", authUser.id)
      .in("post_id", postIds);

    likedSet = new Set((likes ?? []).map((l: { post_id: string }) => l.post_id));
  }

  const result = posts.map((post: Record<string, unknown>, index: number) => ({
    ...post,
    display_url: post.display_url ?? null,
    influencer: post.influencers,
    influencers: undefined,
    is_liked: likedSet.has(post.id as string),
    rank: index + 1,
  }));

  return jsonResponse(result, 200);
}

// ─── POST /posts?action=create ───

async function handleCreate(req: Request): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  const authUser = await requireAuth(supabase);

  const body = await req.json();
  requireFields(body, [
    "influencer_id",
    "product_name",
    "price",
    "category",
    "group_buying_start",
    "group_buying_end",
  ]);

  // 인플루언서 존재 확인 + username 조회
  const { data: influencer, error: infError } = await supabase
    .from("influencers")
    .select("id, username")
    .eq("id", body.influencer_id)
    .single();

  if (infError || !influencer) {
    return errorResponse("influencer_not_found", "Influencer not found", 404);
  }

  const instagramUrl = `https://www.instagram.com/${influencer.username}`;
  const postId = crypto.randomUUID();

  // 1단계: temp URL 그대로 INSERT
  const { error: insertError } = await supabase
    .from("posts")
    .insert({
      id: postId,
      influencer_id: body.influencer_id,
      product_name: body.product_name,
      price: body.price,
      category: body.category,
      group_buying_start: body.group_buying_start,
      group_buying_end: body.group_buying_end,
      group_buying_url: instagramUrl,
      submitted_by: authUser.id,
      post_url: instagramUrl,
      posted_at: new Date().toISOString(),
      ...(body.display_url !== undefined && { display_url: body.display_url }),
    });

  if (insertError) {
    return errorResponse("insert_error", insertError.message, 500);
  }

  const { data, error: fetchError } = await supabase
    .from("posts")
    .select(
      "id, product_name, price, category, display_url, group_buying_start, group_buying_end, group_buying_url, likes_count, posted_at, influencers(id, username, full_name, profile_pic_url, external_url)"
    )
    .eq("id", postId)
    .single();

  if (fetchError || !data) {
    return errorResponse("fetch_error", fetchError?.message ?? "Not found", 500);
  }

  const result = {
    ...data,
    display_url: data.display_url ?? null,
    influencer: data.influencers,
    influencers: undefined,
    is_liked: false,
  };

  return jsonResponse(result, 201);
}

// ─── PUT /posts?action=update ───

async function handleUpdate(req: Request): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  await requireAuth(supabase);

  const body = await req.json();
  requireFields(body, ["post_id"]);

  const updates: Record<string, unknown> = {};
  const allowedFields = [
    "product_name",
    "price",
    "category",
    "group_buying_start",
    "group_buying_end",
  ];

  for (const field of allowedFields) {
    if (body[field] !== undefined) {
      updates[field] = body[field];
    }
  }

  if (Object.keys(updates).length === 0) {
    return errorResponse("no_fields_to_update", "No fields to update", 400);
  }

  const { data, error } = await supabase
    .from("posts")
    .update(updates)
    .eq("id", body.post_id)
    .select()
    .single();

  if (error) {
    if (error.code === "PGRST116") {
      return errorResponse("not_found", "Post not found", 404);
    }
    return errorResponse("update_error", error.message, 500);
  }

  return jsonResponse(data, 200);
}

// ─── DELETE /posts?action=delete ───

async function handleDelete(req: Request): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  await requireAuth(supabase);

  const body = await req.json();
  requireFields(body, ["post_id"]);

  await supabase
    .from("posts")
    .delete()
    .eq("id", body.post_id);

  return new Response(null, { status: 204, headers: corsHeaders });
}

// ─── GET /posts?action=schedule ───
// 내가 팔로우한 인플루언서의 공구 일정 조회
// Query params: start_date (YYYY-MM-DD), end_date (YYYY-MM-DD), page, limit

async function handleSchedule(req: Request, url: URL): Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  const authUser = await requireAuth(supabase);

  const startDate = url.searchParams.get("start_date");
  const endDate = url.searchParams.get("end_date");

  if (!startDate || !endDate) {
    return errorResponse("invalid_params", "start_date and end_date are required", 400);
  }

  const page = Math.max(1, parseIntParam(url, "page", 1));
  const limit = Math.min(50, Math.max(1, parseIntParam(url, "limit", 20)));
  const offset = (page - 1) * limit;

  // 1. 내가 팔로우한 인플루언서 ID 목록
  const { data: follows } = await supabase
    .from("follows")
    .select("influencer_id")
    .eq("user_id", authUser.id);

  const influencerIds = (follows ?? []).map(
    (f: { influencer_id: string }) => f.influencer_id
  );

  if (influencerIds.length === 0) {
    return jsonResponse({ data: [], meta: { page, limit, total: 0 } }, 200);
  }

  // 2. 날짜 필터 + 팔로우 인플루언서 posts 조회
  // 조건: group_buying_start <= end_date AND group_buying_end >= start_date
  const { data, error, count } = await supabase
    .from("posts")
    .select(
      `id, post_url, display_url, product_name, price, category,
       group_buying_start, group_buying_end, likes_count,
       influencers!influencer_id(id, username, full_name, profile_pic_url)`,
      { count: "exact" }
    )
    .in("influencer_id", influencerIds)
    .lte("group_buying_start", `${endDate}T23:59:59+09:00`)
    .gte("group_buying_end", `${startDate}T00:00:00+09:00`)
    .not("group_buying_start", "is", null)
    .not("group_buying_end", "is", null)
    .order("group_buying_end", { ascending: true })
    .range(offset, offset + limit - 1);

  if (error) {
    return errorResponse("query_error", error.message, 500);
  }

  const posts = data ?? [];

  // 3. is_liked 처리
  let likedSet: Set<string> = new Set();
  if (posts.length > 0) {
    const postIds = posts.map((p: { id: string }) => p.id);
    const { data: likes } = await supabase
      .from("likes")
      .select("post_id")
      .eq("user_id", authUser.id)
      .in("post_id", postIds);

    likedSet = new Set(
      (likes ?? []).map((l: { post_id: string }) => l.post_id)
    );
  }

  const result = posts.map((post: Record<string, unknown>) => ({
    ...post,
    display_url: post.display_url ?? null,
    influencer: post.influencers,
    influencers: undefined,
    is_liked: likedSet.has(post.id as string),
  }));

  return jsonResponse(
    { data: result, meta: { page, limit, total: count ?? 0 } },
    200
  );
}
