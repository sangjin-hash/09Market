-- ============================================
-- 09Market DB Schema
-- ============================================

-- 1. influencers
CREATE TABLE influencers (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  biography TEXT,
  profile_pic_url TEXT,
  followers_count INTEGER DEFAULT 0,
  external_url TEXT,
  external_url_title TEXT,
  category TEXT,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_influencers_username ON influencers(username);
CREATE INDEX idx_influencers_category ON influencers(category);

-- 2. posts
CREATE TABLE posts (
  id TEXT PRIMARY KEY,
  influencer_id TEXT NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  post_url TEXT NOT NULL,
  post_type TEXT,
  caption TEXT,
  display_url TEXT,
  image_urls TEXT[],
  hashtags TEXT[],
  group_buying_start TIMESTAMPTZ,
  group_buying_end TIMESTAMPTZ,
  product_name TEXT,
  group_buying_url TEXT,
  posted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_posts_influencer ON posts(influencer_id);
CREATE INDEX idx_posts_influencer_posted ON posts(influencer_id, posted_at DESC);
CREATE INDEX idx_posts_posted_at ON posts(posted_at DESC);

-- 3. influencer_suggestions
CREATE TABLE influencer_suggestions (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  instagram_username TEXT NOT NULL
);
