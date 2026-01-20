# Task ID: 6

**Title:** Implement AuthenticationService with Apple Sign-In and Email

**Status:** completed

**Dependencies:** 1, 2

**Priority:** high

**Description:** Wrap Supabase Auth with Apple Sign-In (primary) and Email/Password using @Observable (FR-1.1, FR-1.2, FR-1.3, FR-1.4, FR-1.5)

**Details:**

Create AuthenticationService with SupabaseClient. Implement signInWithApple(), signInWithEmail(), getSession(), signOut(). Use ASAuthorizationAppleIDProvider. CRITICAL: Persist session across app launches with Supabase Auth auto-refresh tokens (FR-1.3). Implement signOut() to clear local cached data, Keychain entries, and invalidate Supabase session (FR-1.4). Handle errors with os.Logger.

**Test Strategy:**

Test Apple Sign-In flow completes, Email auth works, session persists across app restarts (FR-1.3), sign-out clears all local data and Keychain (FR-1.4).
