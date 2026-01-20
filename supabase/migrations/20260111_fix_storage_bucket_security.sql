-- Migration: Fix Storage Bucket Security
-- Date: 2026-01-11
-- Issue: Public bucket allows anyone to access user images via URL pattern guessing

-- Step 1: Make the bucket private
UPDATE storage.buckets
SET public = false
WHERE id = 'sneaker-images';

-- Step 2: Drop existing permissive policies if any
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- Step 3: Create secure RLS policies

-- Policy: Users can only view their own images
-- The path structure is: {user_id}/{check_id}/img_{n}.jpg
CREATE POLICY "Users can view own images"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'sneaker-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can upload to their own folder
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'sneaker-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can delete their own images
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'sneaker-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Service role can access all images (for Edge Functions)
CREATE POLICY "Service role full access"
ON storage.objects
TO service_role
USING (bucket_id = 'sneaker-images')
WITH CHECK (bucket_id = 'sneaker-images');

-- Verification query (run manually to check):
-- SELECT id, name, public FROM storage.buckets WHERE id = 'sneaker-images';
