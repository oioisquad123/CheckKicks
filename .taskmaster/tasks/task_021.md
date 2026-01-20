# Task ID: 21

**Title:** Set up TestFlight beta and internal testing infrastructure

**Status:** pending

**Dependencies (21A - Core Features):** 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 18, 19, 20, 22, 23, 24

**Dependencies (21B - Monetization):** 14, 15, 16, 17

**Priority:** high

**Phase:** Split into 21A (after polish) and 21B (after monetization)

**Description:** Configure App Store Connect, upload beta build to TestFlight, set up crash analytics (PRD Week 4)

**⚠️ RECOMMENDED APPROACH - Split into Two Beta Phases:**

**Phase 21A: Core Features Beta (Week 3)**
- Test WITHOUT subscription/paywall
- Focus: Core authentication flow, UX, stability
- Dependencies: Tasks 1-13, 18-20, 22-24
- Goal: Validate core product value and usability

**Phase 21B: Monetization Beta (Week 4)**
- Test WITH subscription/paywall
- Focus: Purchase flow, conversion, payment testing
- Dependencies: Tasks 14-17
- Goal: Validate pricing and subscription mechanics

**Rationale:** Testing core features first (without monetization friction) provides better feedback on the fundamental product. Once core is stable, add monetization and test conversion separately.

**Details:**

Create App Bundle ID 'com.auntentic.app' in Apple Developer. Configure App Store Connect with app metadata. Archive release build (Product > Archive). Upload to TestFlight via Xcode Organizer. Add internal testing group. Set up Xcode Crash Organizer for crash analytics. Configure build number auto-increment. Test StoreKit Configuration with sandbox account. Document beta testing process. Target: 99%+ crash-free rate per PRD metrics.

**Test Strategy:**

Upload build successfully, install via TestFlight on test device, verify crash logs appear in Xcode Organizer, StoreKit sandbox purchases work.
