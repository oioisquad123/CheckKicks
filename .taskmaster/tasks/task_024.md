# Task ID: 24

**Title:** Create onboarding tutorial for first-time users

**Status:** done

**Dependencies:** 5

**Priority:** medium

**Description:** Design and implement 3-4 screen onboarding flow explaining app features (FR-8.3) - Phase 2

**Details:**

Create OnboardingView with TabView + PageTabViewStyle for horizontal swipe. Screen 1: "Welcome to CheckKicks - AI-Powered Sneaker Authentication". Screen 2: "How It Works" - illustrate 4-photo capture process. Screen 3: "Get Instant Results" - show confidence score example. Screen 4: "Start with 1 Free Check" - CTA button. Use @AppStorage("hasSeenOnboarding") to show only once. Skip button on all screens. Smooth animations with .transition(.slide). Matches app color scheme (deep navy #1E3A5F).

**Test Strategy:**

Launch app as new user, verify onboarding shows once, can swipe through screens, skip works, "Get Started" dismisses and shows auth screen.
