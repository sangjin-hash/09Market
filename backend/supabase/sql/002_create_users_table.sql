-- ============================================
-- 09Market Users Table
-- 앱 사용자 프로필 정보 (소셜 로그인 유저만 저장)
-- 익명 유저는 row 없음 → GET /me 시 200 -> null 리턴
-- ============================================

-- 1. users 테이블
CREATE TABLE public.users (
  id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT,
  profile_url TEXT,
  provider TEXT NOT NULL DEFAULT 'unknown',   -- 'google', 'apple'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- 2. RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 본인 row만 조회 가능
CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- 본인 row만 수정 가능
CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- 본인 row만 생성 가능 (트리거 또는 직접 생성)
CREATE POLICY "users_insert_own" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. 소셜 로그인 시 자동으로 users row 생성
--    Google: raw_user_meta_data->>'full_name', raw_user_meta_data->>'avatar_url'
--    Apple:  raw_user_meta_data->>'full_name' (첫 로그인에만 제공)
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

-- 소셜 로그인으로 가입 시 자동 실행
CREATE TRIGGER on_social_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_social_login();
