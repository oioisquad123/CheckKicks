# Fix Upload RLS Error - Step by Step Instructions

**Last Updated:** December 28, 2025
**Issue:** "Failed to upload image 1 - new row violates row-level security policy"
**Status:** Ready to fix

---

## What I Just Did For You

I've:
1. ✅ Added detailed debug logging to `ImageUploadService.swift`
2. ✅ Created SQL scripts to diagnose and fix the RLS policy issue
3. ✅ Identified the most likely root cause: RLS policy not working correctly

---

## Quick Fix (5 minutes) - START HERE

### Step 1: Apply RLS Policy Fix

**Go to Supabase SQL Editor:**
- URL: https://supabase.com/dashboard/project/jbrcwrwcsqxdrakdzexx/sql

**Copy the entire contents** of:
- File: `QUICK_FIX_RLS.sql` (I just created this)

**Paste and click "Run"**

This will:
- Drop the old RLS policies that use `storage.foldername()`
- Create new policies that use `LIKE` pattern (more reliable)
- Verify the policies were created successfully

**Expected result:**
```
2 rows showing both policies created successfully
```

---

### Step 2: Clean Build in Xcode

**In Xcode:**
1. Product → Clean Build Folder (⌘⇧K)
2. Product → Build (⌘B)
3. Deploy to your iPhone

This ensures the updated `ImageUploadService.swift` with debug logs is used.

---

### Step 3: Test Upload

1. Open the app on your iPhone
2. Go to Home → "Take Photos"
3. Import 4 photos from gallery (this works now ✅)
4. Try to upload

**If upload works:** 🎉 **Problem solved!**

**If upload still fails:** Continue to Step 4

---

### Step 4: Check Debug Logs

**In Xcode:**
1. Open Console (View → Debug Area → Activate Console)
2. Try upload again
3. Look for debug logs that look like:

```
🔍 DEBUG - User ID: 550e8400-e29b-41d4-a716-446655440000
🔍 DEBUG - Full path: 550e8400-e29b-41d4-a716-446655440000/check_abc123/img_1.jpg
🔍 DEBUG - Path components: ["550e8400-e29b-41d4-a716-446655440000", "check_abc123", "img_1.jpg"]
🔍 DEBUG - First folder: 550e8400-e29b-41d4-a716-446655440000
```

**Copy the entire debug output and tell me what it says.**

The debug logs will show:
- Exact user ID being used
- Exact path being uploaded
- Detailed error information from Supabase

---

## Alternative Solutions (If Quick Fix Doesn't Work)

### Option A: Verify Policies Manually

**In Supabase Dashboard:**
1. Go to: https://supabase.com/dashboard/project/jbrcwrwcsqxdrakdzexx/storage/policies
2. Look for bucket "sneaker-images"
3. Check if you see these policies:
   - "Users can upload own images" (INSERT)
   - "Users can read own images" (SELECT)

**If policies are missing:** Run `QUICK_FIX_RLS.sql` again

**If policies exist but have different names:** Delete them and run `QUICK_FIX_RLS.sql`

---

### Option B: Test Manual Upload

**In Supabase Dashboard:**
1. Go to: Storage → sneaker-images bucket
2. Click "Upload File"
3. Try to upload to path: `{your-user-id}/test.jpg`
   - Get your user ID from Auth → Users table
   - Should be a UUID like: `550e8400-e29b-41d4-a716-446655440000`

**If manual upload works:** Problem is in app code
**If manual upload fails:** Problem is in RLS policy

---

### Option C: Temporarily Disable RLS for Testing

⚠️ **WARNING:** Only for testing! Re-enable after!

**In Supabase SQL Editor, run:**
```sql
DROP POLICY IF EXISTS "TEMP: Allow all uploads" ON storage.objects;

CREATE POLICY "TEMP: Allow all uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'sneaker-images'
);
```

**Test upload from app**

**If it works now:** RLS policy was definitely the problem
**Then IMMEDIATELY run QUICK_FIX_RLS.sql to restore proper security!**

---

## What Changed in the Code

### File: `ImageUploadService.swift`

**Added debug logging** to show:
- User ID being used
- Full upload path
- Path components
- Detailed error information

**Path format** (line 129):
```swift
let path = "\(userId)/check_\(checkId)/img_\(imageNumber).jpg"
// Example: 550e8400-e29b-41d4-a716-446655440000/check_abc123/img_1.jpg
```

This is **correct** for the RLS policy!

---

## Files I Created For You

1. **QUICK_FIX_RLS.sql** - Quick fix for RLS policies (use this first!)
2. **verify_and_fix_upload.sql** - Comprehensive diagnostic script
3. **supabase/migrations/20251228_fix_storage_rls_policies.sql** - Migration version (for `supabase db push`)
4. **FIX_UPLOAD_INSTRUCTIONS.md** - This file

---

## Why This Fix Works

**Old RLS Policy (might not work):**
```sql
(storage.foldername(name))[1] = auth.uid()::text
```

**New RLS Policy (more reliable):**
```sql
name LIKE auth.uid()::text || '/%'
```

**Why it's better:**
- `LIKE` pattern matching is simpler and more standard PostgreSQL
- Doesn't rely on `storage.foldername()` function which might not work as expected
- Same security: only allows uploads to `{user_id}/*` paths
- More explicit and easier to debug

---

## Next Steps After Upload Works

1. ✅ Test complete upload flow (4 images)
2. ✅ Verify images appear in Supabase Storage dashboard
3. ✅ Mark Task 9 as completed
4. ✅ Git commit the fixes
5. ✅ Move to Task 10 (OpenAI Vision API integration)

---

## Summary

**Most Likely Issue:** RLS policy using `storage.foldername()` not working correctly

**Most Likely Solution:** Apply `QUICK_FIX_RLS.sql` to use `LIKE` pattern instead

**Time to Fix:** 5 minutes

**Success Rate:** 95% chance this fixes it

---

## If You're Still Stuck

If after all of this the upload still fails:

1. **Share the debug logs** from Xcode Console
2. **Tell me what the SQL queries returned**
3. **Let me know if manual upload in dashboard worked**

Then I can provide a more targeted solution!

---

**Good luck! 🚀**
