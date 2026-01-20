# Task ID: 8

**Title:** Implement photo review screen with retake and gallery import

**Status:** completed

**Dependencies:** 7

**Priority:** high

**Description:** Review screen showing 4-photo grid with retake individual photos or import from gallery (FR-2.8, FR-2.9)

**Details:**

Grid view of 4 images with delete/retake buttons per photo. Full gallery picker via PHPickerViewController for iOS 14+. Compress images to <1MB using JPEG 0.8 quality before storage.

**Test Strategy:**

Take 4 photos, retake one, import from gallery, verify compression reduces file size appropriately.
