-- Migration: Make sneaker-images bucket public
-- Created: 2025-12-31
-- Description: Update storage bucket from private to public so OpenAI Vision API can access images directly
-- Reason: Edge Function was failing because OpenAI couldn't access signed URLs from private bucket

-- ============================================================================
-- UPDATE STORAGE BUCKET CONFIGURATION
-- ============================================================================

-- Make the bucket public
UPDATE storage.buckets
SET public = true
WHERE id = 'sneaker-images';

-- Verify the update
SELECT id, name, public, file_size_limit
FROM storage.buckets
WHERE id = 'sneaker-images';

-- ============================================================================
-- NOTES
-- ============================================================================
--
-- This change makes all images in the sneaker-images bucket publicly accessible.
-- Images can now be accessed via public URLs without signed tokens.
--
-- Public URL format:
-- https://{project_ref}.supabase.co/storage/v1/object/public/sneaker-images/{user_id}/{check_id}/img_{n}.jpg
--
-- Security considerations:
-- - Images are still organized by user_id, providing some obscurity
-- - RLS policies on database tables still protect metadata
-- - Only users with direct URLs can access images (not listed publicly)
--
-- Benefits:
-- - OpenAI Vision API can access images without authentication
-- - Simpler Edge Function (no need to download and convert to base64)
-- - Faster processing (direct URL access)
-- - More reliable (fewer points of failure)
--
-- ============================================================================
