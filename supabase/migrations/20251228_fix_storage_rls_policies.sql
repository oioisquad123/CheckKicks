-- Migration: Fix Storage RLS Policies for Image Upload
-- Task ID: 9
-- Created: 2025-12-28
-- Description: Replace storage.foldername() with simpler, more reliable RLS policy

-- ============================================================================
-- DROP EXISTING POLICIES
-- ============================================================================

DROP POLICY IF EXISTS "Users can upload own images" ON storage.objects;
DROP POLICY IF EXISTS "Users can read own images" ON storage.objects;

-- ============================================================================
-- CREATE NEW SIMPLIFIED POLICIES
-- ============================================================================

-- Policy 1: Allow authenticated users to upload their own images
-- Uses LIKE pattern matching (more reliable than foldername() function)
-- Path must start with: {user_id}/
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'sneaker-images' AND
  name LIKE auth.uid()::text || '/%'
);

-- Policy 2: Allow authenticated users to read their own images
CREATE POLICY "Users can read own images"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'sneaker-images' AND
  name LIKE auth.uid()::text || '/%'
);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- You can verify these policies by running:
-- SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';
