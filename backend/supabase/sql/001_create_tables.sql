-- ============================================
-- 09Market DB Schema
-- ============================================

-- 1. influencers (인플루언서 정보)
CREATE TABLE public.influencers (
  id TEXT NOT NULL,                              -- 인플루언서 고유 ID
  username TEXT NOT NULL UNIQUE,                 -- 인스타그램 사용자명
  full_name TEXT,                                -- 실명 또는 표시 이름
  biography TEXT,                                -- 인스타그램 자기소개
  profile_pic_url TEXT,                          -- 프로필 사진 URL
  followers_count INTEGER DEFAULT 0,             -- 팔로워 수
  external_url TEXT,                             -- 외부 링크 URL (공동구매 링크 등)
  external_url_title TEXT,                       -- 외부 링크 제목
  category TEXT,                                 -- 인플루언서 카테고리 (뷰티, 패션 등)
  last_synced_at TIMESTAMPTZ,                    -- 마지막 데이터 동기화 시각
  created_at TIMESTAMPTZ DEFAULT NOW(),          -- 레코드 생성 시각
  updated_at TIMESTAMPTZ DEFAULT NOW(),          -- 레코드 수정 시각
  CONSTRAINT influencers_pkey PRIMARY KEY (id)
);

CREATE INDEX idx_influencers_username ON public.influencers(username);
CREATE INDEX idx_influencers_category ON public.influencers(category);

-- 2. posts (인플루언서 게시물)
CREATE TABLE public.posts (
  id TEXT NOT NULL,                              -- 게시물 고유 ID
  influencer_id TEXT NOT NULL,                   -- 작성 인플루언서 ID (FK)
  post_url TEXT NOT NULL,                        -- 게시물 원본 URL
  post_type TEXT,                                -- 게시물 유형 (image, video, carousel 등)
  caption TEXT,                                  -- 게시물 본문 텍스트
  display_url TEXT,                              -- 대표 이미지 URL
  image_urls TEXT[],                             -- 게시물 이미지 URL 목록
  hashtags TEXT[],                               -- 해시태그 목록
  group_buying_start TIMESTAMPTZ,                -- 공동구매 시작일
  group_buying_end TIMESTAMPTZ,                  -- 공동구매 종료일
  product_name TEXT,                             -- 공동구매 상품명
  group_buying_url TEXT,                         -- 공동구매 참여 링크
  posted_at TIMESTAMPTZ,                         -- 게시물 작성 시각
  created_at TIMESTAMPTZ DEFAULT NOW(),          -- 레코드 생성 시각
  updated_at TIMESTAMPTZ DEFAULT NOW(),          -- 레코드 수정 시각
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_influencer_id_fkey FOREIGN KEY (influencer_id) REFERENCES public.influencers(id)
);

CREATE INDEX idx_posts_influencer ON public.posts(influencer_id);
CREATE INDEX idx_posts_influencer_posted ON public.posts(influencer_id, posted_at DESC);
CREATE INDEX idx_posts_posted_at ON public.posts(posted_at DESC);

-- 3. influencer_suggestions (인플루언서 추천 요청)
CREATE TABLE public.influencer_suggestions (
  id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL, -- 자동 증가 고유 ID
  instagram_username TEXT NOT NULL,                 -- 추천할 인스타그램 사용자명
  CONSTRAINT influencer_suggestions_pkey PRIMARY KEY (id)
);
