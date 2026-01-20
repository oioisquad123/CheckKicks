-- Migration: Create Supabase Storage bucket for sneaker images
-- Task ID: 4
-- Created: 2025-12-26
-- Description: Create 'sneaker-images' bucket with private access and RLS policies

-- ============================================================================
-- CREATE STORAGE BUCKET
-- ============================================================================

-- Insert the sneaker-images bucket
-- Note: Using INSERT with ON CONFLICT to make this migration idempotent
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'sneaker-images',
    'sneaker-images',
    false,  -- Private bucket (not publicly accessible)
    52428800,  -- 50MB file size limit (50 * 1024 * 1024)
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/heic']  -- Allowed image types
)
ON CONFLICT (id) DO UPDATE SET
    public = false,
    file_size_limit = 52428800,
    allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/heic'];

-- ============================================================================
-- BUCKET CONFIGURATION DETAILS
-- ============================================================================

-- Bucket Name: sneaker-images
-- Privacy: Private (public = false)
-- File Size Limit: 50MB per file
-- Allowed MIME Types: JPEG, JPG, PNG, WebP, HEIC
-- User Folder Structure: {user_id}/image_name.ext

-- ============================================================================
-- RLS POLICIES (Applied via previous migration)
-- ============================================================================

-- Note: RLS policies were already created in migration 20251225_storage_rls_policies.sql
-- Policies include:
-- 1. Users can upload own images (INSERT)
-- 2. Users can read own images (SELECT)
--
-- These policies enforce user-specific folders using the pattern:
-- (storage.foldername(name))[1] = auth.uid()::text
