-- ============================================
-- Storage RLS Policies for 'media' bucket
--
-- 사전 조건: Supabase Dashboard에서 media 버킷 생성
--   - Bucket Name: media
--   - Public: ON
--   - File size limit: 10MB
--   - Allowed MIME types: image/jpeg, image/png, image/heic, image/webp
-- ============================================

-- 1. SELECT: 전체 공개 (Public 버킷이므로 URL 직접 접근 가능하지만, API 접근도 허용)
CREATE POLICY "media_select_public"
ON storage.objects FOR SELECT
USING (bucket_id = 'media');

-- 2. INSERT: 인증 유저 → temp/ 경로만 업로드 가능
CREATE POLICY "media_insert_temp"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'media'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = 'temp'
);

-- 3. DELETE: 인증 유저 → 본인이 업로드한 temp/ 파일만 삭제 가능
CREATE POLICY "media_delete_temp_own"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'media'
  AND auth.uid() = owner
  AND (storage.foldername(name))[1] = 'temp'
);

-- 참고: service_role은 RLS를 bypass하므로 별도 정책 불필요
-- Edge Function에서 service_role 클라이언트로 users/, influencers/, posts/ 경로 접근
