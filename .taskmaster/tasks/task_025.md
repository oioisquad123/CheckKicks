# Task ID: 25

**Title:** Implement push notifications for authentication results

**Status:** pending

**Dependencies:** 11, 21

**Priority:** low

**Description:** Send push notification when AI analysis completes if app is backgrounded (FR-8.4) - Phase 2

**Details:**

Request notification permissions with UNUserNotificationCenter. Modify Edge Function to optionally accept FCM/APNS token and trigger notification on completion. Use UserNotifications framework to show local notification: "Your sneaker check is ready!" with deep link to result. Handle notification tap to navigate directly to ResultView. Badge icon with unread results count. Settings toggle to enable/disable notifications. Consider using Supabase Realtime subscriptions as alternative to polling.

**Test Strategy:**

Start check, background app, verify notification appears when result ready, tap notification opens app to result screen.
