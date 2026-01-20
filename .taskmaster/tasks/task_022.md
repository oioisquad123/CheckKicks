# Task ID: 22

**Title:** Handle AI request for additional photos if needed

**Status:** pending

**Dependencies:** 11, 12

**Priority:** low

**Description:** Implement flow for AI to request additional specific photos before final verdict (FR-4.5)

**Details:**

Modify Edge Function response handling to check for 'additionalPhotosNeeded' array. If present, show alert: "AI needs additional photos: [angles]". Present photo capture for requested angles only (e.g., "sole close-up", "heel detail"). Re-upload new photos and re-invoke Edge Function. Update system prompt to guide AI on when to request more photos (e.g., if size tag unreadable, stitching unclear). Limit to 1 additional photo request to avoid infinite loops.

**Test Strategy:**

Simulate Edge Function returning additionalPhotosNeeded, verify app prompts for specific angles, re-submits with new photos, eventually gets final verdict.
