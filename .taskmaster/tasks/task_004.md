# Task ID: 4

**Title:** Set up Supabase Storage bucket with RLS for user images

**Status:** completed

**Dependencies:** 2

**Priority:** high

**Description:** Configure user-specific image storage with secure RLS policies (FR-0.5)

**Details:**

Create 'sneaker-images' bucket with public=false. Add RLS policy: INSERT/SELECT/UPDATE only for auth.uid() = owner. Create user folders dynamically via signed URLs.

**Test Strategy:**

Test upload as authenticated user succeeds, unauthenticated fails, wrong user cannot access images.
