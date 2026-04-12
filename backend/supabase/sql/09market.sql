-- ============================================
-- 09Market 통합 DB Schema
-- 이 파일 하나로 전체 스키마 구성
-- ============================================

-- ============================================
-- 1. influencers (인플루언서 정보)
-- ============================================
CREATE TABLE public.influencers (
  id TEXT NOT NULL,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT,
  biography TEXT,
  profile_pic_url TEXT,
  followers_count INTEGER DEFAULT 0,
  external_url TEXT,
  external_url_title TEXT,
  category TEXT,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT influencers_pkey PRIMARY KEY (id)
);

CREATE INDEX idx_influencers_username ON public.influencers(username);
CREATE INDEX idx_influencers_category ON public.influencers(category);

ALTER TABLE public.influencers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "influencers_select" ON public.influencers FOR SELECT USING (TRUE);


-- ============================================
-- 2. users (앱 사용자 프로필)
--    소셜 로그인 유저만 저장. 익명 유저는 row 없음.
-- ============================================
CREATE TABLE public.users (
  id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT,
  profile_url TEXT,
  provider TEXT NOT NULL DEFAULT 'unknown',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_select_own" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users_update_own" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "users_insert_own" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- 소셜 로그인 시 자동으로 users row 생성
CREATE OR REPLACE FUNCTION public.handle_social_login()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF NEW.is_anonymous = false THEN
    INSERT INTO public.users (id, nickname, profile_url, provider)
    VALUES (
      NEW.id,
      COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name'
      ),
      NEW.raw_user_meta_data->>'avatar_url',
      COALESCE(NEW.raw_app_meta_data->>'provider', 'unknown')
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_social_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_social_login();


-- ============================================
-- 3. posts (인플루언서 게시물 / 공동구매)
-- ============================================
CREATE TABLE public.posts (
  id TEXT NOT NULL,
  influencer_id TEXT NOT NULL,
  post_url TEXT NOT NULL,
  post_type TEXT,
  caption TEXT,
  display_url TEXT,
  hashtags TEXT[],
  group_buying_start TIMESTAMPTZ,
  group_buying_end TIMESTAMPTZ,
  product_name TEXT,
  group_buying_url TEXT,
  price INTEGER,
  category TEXT,
  submitted_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  likes_count INTEGER DEFAULT 0,
  posted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_influencer_id_fkey FOREIGN KEY (influencer_id) REFERENCES public.influencers(id)
);

CREATE INDEX idx_posts_influencer ON public.posts(influencer_id);
CREATE UNIQUE INDEX idx_posts_dedup ON public.posts(influencer_id, product_name, group_buying_start, group_buying_end)
  WHERE product_name IS NOT NULL AND group_buying_start IS NOT NULL AND group_buying_end IS NOT NULL;
CREATE INDEX idx_posts_influencer_posted ON public.posts(influencer_id, posted_at DESC);
CREATE INDEX idx_posts_posted_at ON public.posts(posted_at DESC);
CREATE INDEX idx_posts_category ON public.posts(category);
CREATE INDEX idx_posts_submitted_by ON public.posts(submitted_by);
CREATE INDEX idx_posts_likes_count ON public.posts(likes_count DESC);

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "posts_select" ON public.posts FOR SELECT USING (TRUE);
CREATE POLICY "posts_insert" ON public.posts FOR INSERT WITH CHECK (auth.uid() = submitted_by);
CREATE POLICY "posts_update" ON public.posts FOR UPDATE USING (auth.uid() = submitted_by);
CREATE POLICY "posts_delete" ON public.posts FOR DELETE USING (auth.uid() = submitted_by);


-- ============================================
-- 4. influencer_suggestions (인플루언서 등록 요청)
-- ============================================
CREATE TABLE public.influencer_suggestions (
  id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
  instagram_username TEXT NOT NULL,
  status TEXT DEFAULT 'processing',
  error_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT influencer_suggestions_pkey PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_suggestions_username ON public.influencer_suggestions(instagram_username);

ALTER TABLE public.influencer_suggestions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "suggestions_select" ON public.influencer_suggestions FOR SELECT USING (TRUE);


-- ============================================
-- 5. likes (좋아요)
-- ============================================
CREATE TABLE public.likes (
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  post_id TEXT REFERENCES public.posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, post_id)
);

CREATE INDEX idx_likes_user_id ON public.likes(user_id);
CREATE INDEX idx_likes_post_id ON public.likes(post_id);

ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "likes_select" ON public.likes FOR SELECT USING (TRUE);
CREATE POLICY "likes_insert" ON public.likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "likes_delete" ON public.likes FOR DELETE USING (auth.uid() = user_id);

-- likes_count 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION public.update_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_likes_count
  AFTER INSERT OR DELETE ON public.likes
  FOR EACH ROW EXECUTE FUNCTION public.update_likes_count();


-- ============================================
-- 6. follows (인플루언서 팔로우)
-- ============================================
CREATE TABLE public.follows (
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  influencer_id TEXT REFERENCES public.influencers(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, influencer_id)
);

CREATE INDEX idx_follows_user_id ON public.follows(user_id);
CREATE INDEX idx_follows_influencer_id ON public.follows(influencer_id);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "follows_select" ON public.follows FOR SELECT USING (TRUE);
CREATE POLICY "follows_insert" ON public.follows FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "follows_delete" ON public.follows FOR DELETE USING (auth.uid() = user_id);
