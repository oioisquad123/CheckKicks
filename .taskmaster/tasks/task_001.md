# Task ID: 1

**Title:** Create Xcode project and integrate Supabase Swift SDK

**Status:** completed

**Dependencies:** None

**Priority:** high

**Description:** Set up new Xcode project targeting iOS 17.0+ with SwiftUI and add Supabase Swift SDK via SPM (FR-0.1, FR-0.3)

**Details:**

Create new SwiftUI project in Xcode 16+ targeting iOS 17.0 deployment. Add Supabase Swift SDK via File > Add Package Dependencies with URL 'https://github.com/supabase/supabase-swift.git' from version 2.0.0. Configure Info.plist for camera/photo library permissions. Use @main App struct with WindowGroup.

**Test Strategy:**

Verify project builds without errors, SDK imports successfully in test file, simulator launches with SwiftUI preview working.
