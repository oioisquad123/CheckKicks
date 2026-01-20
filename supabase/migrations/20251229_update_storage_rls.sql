-- Update Storage RLS Policies to use LIKE pattern
-- Created: 2025-12-29
-- Fixes: Upload error "new row violates row-level security policy"

-- Drop existing policies
DROP POLICY IF EXISTS "Users can upload own images" ON storage.objects;
DROP POLICY IF EXISTS "Users can read own images" ON storage.objects;

-- Create new policies with ILIKE pattern (case-insensitive, more reliable than foldername)
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'sneaker-images' AND
  name ILIKE auth.uid()::text || '/%'
);

CREATE POLICY "Users can read own images"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'sneaker-images' AND
  name ILIKE auth.uid()::text || '/%'
);
