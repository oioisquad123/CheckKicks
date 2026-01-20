-- QUICK FIX: Replace RLS policies with simpler, more reliable version
-- Copy and paste this ENTIRE script into Supabase SQL Editor
-- URL: https://supabase.com/dashboard/project/jbrcwrwcsqxdrakdzexx/sql

-- ============================================================================
-- Step 1: Drop old policies
-- ============================================================================

DROP POLICY IF EXISTS "Users can upload own images" ON storage.objects;
DROP POLICY IF EXISTS "Users can read own images" ON storage.objects;

-- ============================================================================
-- Step 2: Create new policies using LIKE pattern (more reliable)
-- ============================================================================

-- Upload policy: Allows users to upload to {their_user_id}/*
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'sneaker-images' AND
  name LIKE auth.uid()::text || '/%'
);

-- Read policy: Allows users to read from {their_user_id}/*
CREATE POLICY "Users can read own images"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'sneaker-images' AND
  name LIKE auth.uid()::text || '/%'
);

-- ============================================================================
-- Step 3: Verify policies were created
-- ============================================================================

SELECT
  policyname,
  cmd,
  with_check,
  qual
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage'
  AND policyname IN ('Users can upload own images', 'Users can read own images');

-- Expected: 2 rows showing both policies
