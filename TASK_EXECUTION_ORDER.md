# Task Execution Order - Recommended Sequence
**Last Updated:** January 7, 2026
**Status:** Phase 1C Complete - TestFlight Build Uploaded! 🎉
**Recent Update:** Migrated AI backend to OpenRouter API (Claude Sonnet 4)

---

## 📊 Quick Reference: Task Status

| Status | Count | Tasks |
|--------|-------|-------|
| ✅ Completed | 20/35 | 1-13, 13.5, 18, 19, 21.5, 21A, 23, 24 (Phase 1A + 1B + 1C) |
| ⏳ Pending | 15/35 | 14-17, 20, 21B, 22, 25-27, etc. |
| **Total** | **35** | Including new tasks |

**PM Review Notes (Jan 1, 2026):**
- ✅ Task 13.5 verified as COMPLETE (history service integrated)
- 🔄 **Task 23 (History Screen) moved UP** to Phase 1B - core feature!
- 🔄 Task 20 (Accessibility) moved to Phase 1D - not blocking beta
- 🔄 Task 22 (Additional photos) moved to Phase 1D - edge case
- 🎯 **Goal: Get to TestFlight faster with lean Phase 1B**

**Engineering Updates (Jan 7, 2026):**
- ✅ **Migrated to OpenRouter API** - Now using Claude Sonnet 4 via OpenRouter
- ✅ **Updated reference images** - New Jordan 12 Grey University Blue photos
- ✅ **UI improvements** - Added white backgrounds to reference image overlays
- ✅ **Fixed 401 JWT error** - Redeployed Edge Function with verify_jwt=false
- ✅ **Cleaned up Supabase secrets** - Removed unused ANTHROPIC_API_KEY & OPENAI_API_KEY
- 🎯 **AI Model:** Claude Sonnet 4 (via OpenRouter) - easily switchable to 300+ models

---

## 🎯 Execution Sequence (Follow This Order)

### ✅ Phase 1A: Core MVP Foundation (COMPLETED)
**Status:** 14/14 complete (100%)
**Timeline:** Weeks 1-2 (December 25-31, 2025)

| Order | Task ID | Task Name | Status |
|-------|---------|-----------|--------|
| 1 | Task 1 | Create Xcode project and integrate Supabase Swift SDK | ✅ |
| 2 | Task 2 | Configure Supabase project (Auth, Storage, Database, Edge Functions) | ✅ |
| 3 | Task 3 | Implement Supabase database schema with RLS policies | ✅ |
| 4 | Task 4 | Set up Supabase Storage bucket with RLS | ✅ |
| 5 | Task 5 | Create MVVM folder structure and basic navigation | ✅ |
| 6 | Task 6 | Implement AuthenticationService with Apple Sign-In and Email | ✅ |
| 7 | Task 7 | Build 4-step photo capture wizard with guidance overlays | ✅ |
| 8 | Task 8 | Implement photo review screen with retake and gallery import | ✅ |
| 9 | Task 9 | Implement image upload service to Supabase Storage | ✅ |
| 10 | Task 10 | Deploy Supabase Edge Function authenticate-sneaker with Claude Sonnet 4 (via OpenRouter) | ✅ |
| 11 | Task 11 | Integrate AI analysis flow with loading state | ✅ |
| 12 | Task 12 | Create results screen with verdict, confidence, colors, disclaimer | ✅ |
| 13 | Task 13 | Save authentication results to Supabase database | ✅ |
| 14 | Task 13.5 | Integrate AuthenticationHistoryService into app | ✅ |

**Bonus Completed (Dec 31, 2025):**
- ✅ Fixed AI determinism (temperature: 0)
- ✅ Enhanced photo guidance (detailed tips)
- ✅ Optimized AI prompt for decisive verdicts
- ✅ Fixed navigation buttons ("New Check" vs "Done")

**Bonus Completed (Jan 7, 2026):**
- ✅ Migrated from Anthropic API to OpenRouter API
- ✅ Updated all 6 reference images (Jordan 12 Grey University Blue)
- ✅ Added white backgrounds to reference image UI components
- ✅ Fixed Edge Function 401 JWT authentication error
- ✅ Removed unused API keys from Supabase (ANTHROPIC_API_KEY, OPENAI_API_KEY)

---

### ✅ Phase 1B: Lean MVP for Beta (COMPLETE)
**Status:** 4/4 complete (100%)
**Priority:** HIGH - Get to TestFlight FAST
**Timeline:** Week 3 (Jan 1-7, 2026)
**Goal:** Add essential features → TestFlight → Get user feedback

| Order | Task ID | Task Name | Status | Priority | Est. Time |
|-------|---------|-----------|--------|----------|-----------|
| 15 | **Task 23** | Build authentication history screen (users NEED this!) | ✅ | **CRITICAL** | 4-6 hrs |
| 16 | Task 18 | Implement error handling and network resilience | ✅ | HIGH | 4-6 hrs |
| 17 | Task 19 | Add loading states, animations, and UI polish | ✅ | HIGH | 3-4 hrs |
| 18 | Task 24 | Create onboarding tutorial for first-time users | ✅ | MEDIUM | 3-4 hrs |

**Why This Order (PM Rationale):**

1. **Task 23 (History Screen) is CRITICAL**
   - Users complete authentication... then what?
   - Without history, they can't reference past checks
   - This is a CORE feature, not optional polish
   - AuthenticationHistoryService already exists ✅
   - Just needs the UI built on top

2. **Task 18 (Error Handling) prevents frustration**
   - Network errors without handling = confused users
   - Critical for beta testers to report real issues

3. **Task 19 (Polish) improves perceived quality**
   - Loading states make the app feel responsive
   - Quick wins with high impact

4. **Task 24 (Onboarding) helps new users**
   - Explains how to take good photos
   - Reduces support questions

**Moved to Phase 1D (not blocking beta):**
- Task 20 (Accessibility) - Important but TestFlight won't reject
- Task 22 (Additional photos) - Edge case, AI works without it

---

### ✅ Phase 1C: TestFlight Beta Upload (COMPLETE)
**Status:** 2/2 complete (100%)
**Timeline:** End of Week 3 (Jan 1, 2026) - COMPLETED EARLY!
**Goal:** Upload to TestFlight for internal testing

| Order | Task ID | Task Name | Status | Priority |
|-------|---------|-----------|--------|----------|
| 19 | **NEW 21.5** | Create app icon & assets (1024x1024 + all sizes) | ✅ | HIGH |
| 20 | Task 21A | TestFlight beta - Upload core features (NO subscription) | ✅ | HIGH |

**Focus:** Get the app into TestFlight for real user feedback.

**Completed Jan 1, 2026:**
- ✅ Created premium CheckKicks app icon (sneaker + gold verification badge)
- ✅ Generated all 14 required iOS icon sizes
- ✅ Fixed iCloud entitlements issue for App Store Connect
- ✅ Created archive and uploaded to App Store Connect
- ✅ Build processing in TestFlight

**TestFlight Build Includes:**
- ✅ Photo capture & review
- ✅ AI authentication
- ✅ Results display
- ✅ History screen (Task 23)
- ✅ Basic error handling (Task 18)
- ✅ Loading animations (Task 19)
- ✅ Onboarding (Task 24)
- ❌ NO subscription/paywall yet

---

### 🧪 Phase 1D: Beta Feedback & Polish (Week 4)
**Status:** 0/5 complete (0%)
**Timeline:** Week 4 (Jan 8-14, 2026)
**Goal:** Collect feedback, fix bugs, add polish before monetization

| Order | Task ID | Task Name | Status | Priority |
|-------|---------|-----------|--------|----------|
| 21 | - | Internal beta testing cycle (2-3 days) | ⏳ | HIGH |
| 22 | - | Bug fixes from beta feedback | ⏳ | HIGH |
| 23 | Task 20 | Implement accessibility & VoiceOver support | ⏳ | MEDIUM |
| 24 | Task 22 | Handle AI request for additional photos | ⏳ | LOW |
| 25 | **NEW 20.5** | Performance testing & optimization (<30s flow) | ⏳ | MEDIUM |

**Focus:** Fix issues found in beta, add non-critical polish.

**Beta Testing Checklist:**
- [ ] Test on multiple iPhone models (SE, 13, 14, 15)
- [ ] Test with various sneaker brands
- [ ] Check AI response times
- [ ] Verify history screen loads correctly
- [ ] Test error scenarios (no network, timeout)
- [ ] Collect user feedback on UX

---

### 💰 Phase 1E: Monetization (Week 5)
**Status:** 0/6 complete (0%)
**Timeline:** Week 5

| Order | Task ID | Task Name | Status | Priority |
|-------|---------|-----------|--------|----------|
| 26 | Task 14 | Integrate StoreKit 2 for $9.99/month subscription | ⏳ | HIGH |
| 27 | Task 15 | Implement free check tracking and subscription verification | ⏳ | HIGH |
| 28 | Task 16 | Build paywall screen with StoreKit purchase and restore | ⏳ | HIGH |
| 29 | Task 17 | Sync subscription status to Supabase database | ⏳ | MEDIUM |
| 30 | Task 26 | Build settings screen with account and subscription management | ⏳ | MEDIUM |
| 31 | Task 21B | TestFlight beta - Monetization (WITH subscription) | ⏳ | HIGH |

**Focus:** Add monetization AFTER core product is validated and stable.

**⚠️ Prerequisites Before Starting Phase 1E:**
- [ ] Define FREE vs PREMIUM feature matrix
- [ ] Write paywall value proposition copy
- [ ] Create StoreKit Configuration file
- [ ] Set up App Store Connect subscription product

**Apple Developer Upload #2:** Task 21B - Upload monetization build to TestFlight
- Upload new build with subscription features
- Test purchase flow in sandbox
- Validate restore purchases works
- Test subscription status persistence

---

### 🚀 Phase 2: Launch Preparation (Week 6)
**Status:** 0/4 complete (0%)
**Timeline:** Week 6

| Order | Task ID | Task Name | Status | Priority |
|-------|---------|-----------|--------|----------|
| 32 | **NEW 27.5** | Create and publish Terms of Service & Privacy Policy | ⏳ | HIGH |
| 33 | Task 25 | Implement push notifications for authentication results (OPTIONAL) | ⏳ | LOW |
| 34 | - | Final QA pass and bug fixes | ⏳ | HIGH |
| 35 | Task 27 | App Store submission and marketing assets preparation | ⏳ | HIGH |

**Focus:** Legal compliance and final submission to App Store.

**Apple Developer Upload #3:** Task 27 - Final App Store Submission
- Complete all App Store Connect metadata
- Upload final production build
- Submit for App Review
- Respond to review feedback if needed

---

## 📱 Apple Developer Upload Timeline

### Upload #1: TestFlight Beta - Core Features (Week 4)
**Task:** 21A
**Location:** App Store Connect → TestFlight
**Purpose:** Internal beta testing of core authentication flow
**Includes:**
- ✅ Photo capture & review
- ✅ AI authentication
- ✅ Results display
- ✅ History screen
- ✅ Onboarding
- ❌ NO subscription/paywall

**How to Upload:**
1. Xcode → Product → Archive
2. Distribute App → App Store Connect
3. Upload to App Store Connect
4. Go to App Store Connect → TestFlight
5. Add internal testers
6. Distribute build

---

### Upload #2: TestFlight Beta - Monetization (Week 5)
**Task:** 21B
**Location:** App Store Connect → TestFlight
**Purpose:** Test subscription purchase flow
**Includes:**
- ✅ Everything from Upload #1
- ✅ StoreKit 2 integration
- ✅ Free check tracking
- ✅ Paywall screen
- ✅ Settings with subscription management

**Testing Required:**
- Sandbox Apple ID purchase testing
- Restore purchases validation
- Subscription status persistence
- Expiration handling

---

### Upload #3: App Store Submission (Week 6)
**Task:** 27
**Location:** App Store Connect → App Store
**Purpose:** Public release
**Includes:**
- ✅ Everything from Upload #2
- ✅ Terms of Service & Privacy Policy
- ✅ All marketing assets
- ✅ App Store metadata
- ✅ Final QA pass

**Submission Checklist:**
- [ ] App Store screenshots (all device sizes)
- [ ] App description & keywords
- [ ] Privacy Policy URL
- [ ] Terms of Service URL
- [ ] Support URL
- [ ] App icon 1024x1024
- [ ] Age rating (4+)
- [ ] Category (Utilities or Shopping)
- [ ] Pricing ($9.99/month subscription)
- [ ] Submit for review

---

## 🆕 Missing Tasks to Create

| Task ID | Task Name | Priority | Phase | Status |
|---------|-----------|----------|-------|--------|
| ~~NEW 13.5~~ | ~~Integrate AuthenticationHistoryService~~ | ~~HIGH~~ | ~~1A~~ | ✅ DONE |
| NEW 20.5 | Performance testing & optimization | MEDIUM | 1D | ⏳ |
| NEW 21.5 | Create app icon & assets | HIGH | 1C | ⏳ |
| NEW 27.5 | Terms of Service & Privacy Policy | HIGH | 2 | ⏳ |

**Note:** Task 24.5 (color scheme) removed - not needed, app already has consistent colors.

---

## ✅ Task Dependency Map

```
Phase 1A (Complete):
Tasks 1-13, 13.5 → ALL DONE ✅

Phase 1B (Next - Lean Beta):
Task 23 ← depends on Task 13 (AuthHistoryService already done!)
Task 18 ← depends on Task 11
Task 19 ← depends on Task 12
Task 24 ← depends on Task 5

Phase 1C (TestFlight):
Task NEW 21.5 ← no dependencies
Task 21A ← depends on Tasks 18, 19, 23, 24

Phase 1D (Polish):
Task 20 ← depends on Tasks 5, 7, 12
Task 22 ← depends on Tasks 11, 12
Task NEW 20.5 ← depends on Tasks 11, 13, 18, 19

Phase 1E (Monetization):
Task 14 ← depends on Tasks 5, 13
Task 15 ← depends on Tasks 3, 6, 13, 14
Task 16 ← depends on Tasks 14, 15
Task 17 ← depends on Tasks 3, 16
Task 26 ← depends on Tasks 6, 17
Task 21B ← depends on Tasks 14, 15, 16, 17

Phase 2 (Launch):
Task NEW 27.5 ← no dependencies
Task 25 ← depends on Tasks 11, 21 (optional)
Task 27 ← depends on Tasks 21, 23, 24, 25, 26
```

---

## 📋 Weekly Breakdown (Starting Jan 1, 2026)

### Week 3 (Jan 1-7): Phase 1B + 1C → TestFlight
**Days 1-2 (Jan 1-2):**
- Task 23: History Screen (CRITICAL)
- Task 18: Error handling

**Days 3-4 (Jan 3-4):**
- Task 19: Loading animations & polish
- Task 24: Onboarding tutorial

**Days 5-6 (Jan 5-6):**
- NEW Task 21.5: App icon & assets
- Task 21A: TestFlight setup & upload

**Day 7 (Jan 7):**
- Upload to TestFlight! 🚀
- Start internal beta testing

### Week 4 (Jan 8-14): Phase 1D - Beta Feedback
**Days 1-3 (Jan 8-10):**
- Internal beta testing (2-3 days)
- Collect user feedback
- Log bugs and issues

**Days 4-5 (Jan 11-12):**
- Bug fixes from feedback
- Task 20: Accessibility (if time)

**Days 6-7 (Jan 13-14):**
- Task 22: Additional photos (if needed)
- NEW Task 20.5: Performance optimization
- Prepare for monetization

### Week 5 (Jan 15-21): Phase 1E - Monetization
**Days 1-2:**
- Define FREE vs PREMIUM features
- Task 14: StoreKit 2 integration

**Days 3-4:**
- Task 15: Free check tracking
- Task 16: Paywall screen

**Days 5-6:**
- Task 17: Subscription sync
- Task 26: Settings screen

**Day 7:**
- Task 21B: TestFlight with monetization
- Upload to TestFlight (Build #2)

### Week 6 (Jan 22-28): Phase 2 - Launch
**Days 1-2:**
- NEW Task 27.5: Terms & Privacy Policy
- Marketing assets preparation

**Days 3-4:**
- Final QA pass
- Screenshot creation

**Days 5-7:**
- Task 27: App Store submission
- Submit for review
- Monitor review status

---

## 🎯 Current Status: You Are Here

```
✅ Phase 1A: Core MVP (100% complete) 🎉
   Tasks 1-13.5 ALL DONE - Production-ready authentication flow!
   - Apple Sign-In ✅
   - 6-photo guided capture ✅
   - AI authentication (Claude Sonnet 4 via OpenRouter) ✅
   - Results display ✅
   - Database persistence ✅
   - History service integration ✅
   - BONUS: Deterministic AI & enhanced UX (Dec 31, 2025) ✅
   - BONUS: OpenRouter migration & reference images (Jan 7, 2026) ✅

✅ Phase 1B: Lean MVP for Beta (100% complete) 🎉
   ✅ Task 23 (History Screen) - COMPLETE!
   ✅ Task 18 (Error Handling) - COMPLETE!
   ✅ Task 19 (Loading States & UI Polish) - COMPLETE!
   ✅ Task 24 (Onboarding Tutorial) - COMPLETE!

✅ Phase 1C: TestFlight Upload (100% complete) 🎉
   ✅ Task 21.5 (App Icon) - COMPLETE!
   ✅ Task 21A (TestFlight Upload) - COMPLETE!
   - Build uploaded to App Store Connect Jan 1, 2026
   - OpenRouter API integration deployed Jan 7, 2026

👉 Phase 1D: Beta Feedback & Polish (0% complete) ⬅️ NEXT
   - Wait for TestFlight processing
   - Add internal testers
   - Collect feedback

⏳ Phase 1E: Monetization (0% complete)
⏳ Phase 2: Launch (0% complete)
```

---

## 🚀 Action Items - Phase 1D (Beta Feedback & Polish)

**Phase 1C Complete!** All tasks finished:
- ✅ Task 21.5: App Icon & Assets - Premium CheckKicks icon created
- ✅ Task 21A: TestFlight Upload - Build uploaded to App Store Connect

**Next Steps - Phase 1D:**

1. **Wait for TestFlight Processing** (5-30 minutes)
   - Check App Store Connect for build status
   - Complete Export Compliance questions when prompted

2. **Add Internal Testers**
   - Go to TestFlight → Internal Testing
   - Create tester group
   - Add team members by Apple ID

3. **Start Beta Testing**
   - Enable build for testers
   - Testers download via TestFlight app
   - Collect feedback on authentication flow

4. **Bug Fixes & Polish** (if needed)
   - Task 20: Accessibility (optional)
   - Task 22: Additional photos (optional)
   - Performance optimization

**This Week's Goal:** Get beta feedback from real users!

---

## 📊 Progress Tracking

### Overall Project Progress: 57% Complete

| Phase | Tasks | Complete | Remaining | Progress |
|-------|-------|----------|-----------|----------|
| 1A: Core MVP | 14 | 14 | 0 | ████████████ 100% ✅ |
| 1B: Lean Beta | 4 | 4 | 0 | ████████████ 100% ✅ |
| 1C: TestFlight | 2 | 2 | 0 | ████████████ 100% ✅ |
| 1D: Polish | 5 | 0 | 5 | ░░░░░░░░░░░░ 0% |
| 1E: Monetization | 6 | 0 | 6 | ░░░░░░░░░░░░ 0% |
| 2: Launch | 4 | 0 | 4 | ░░░░░░░░░░░░ 0% |
| **Total** | **35** | **20** | **15** | ███████░░░░░ 57% |

---

## 💡 Pro Tips

**Don't Skip Phases:**
- Each phase builds on the previous one
- Monetization too early = wasted effort if core needs changes
- Testing early = catch issues before they multiply

**Apple Review Timeline:**
- TestFlight: Usually approved within hours
- App Store: Usually 24-48 hours (can be up to 1 week)
- Plan for review time in your schedule

**Sandbox Testing:**
- Create a separate Apple ID for sandbox testing
- Never use your real Apple ID for sandbox
- Sandbox can be flaky - test on device, not just simulator

**Version Numbers:**
- Use semantic versioning: 1.0.0 for first release
- TestFlight builds: increment build number (1, 2, 3...)
- App Store updates: increment version (1.0.0 → 1.1.0)

---

**Remember:** You're 57% done with Phase 1A + 1B + 1C complete! App is now on TestFlight! Next up: Add testers and collect feedback!

**PM Philosophy:** Ship early, iterate often. Perfect is the enemy of shipped!

**Milestones Achieved:**
- **(Jan 1, 2026):** Auntentic v1.0 uploaded to TestFlight! 🎉
- **(Jan 7, 2026):** Migrated to OpenRouter API (Claude Sonnet 4) + Updated reference images! 🚀

---

## 🔧 Technical Configuration

### AI Backend (Edge Function v5.1)
- **API Provider:** OpenRouter (openrouter.ai)
- **Model:** `anthropic/claude-sonnet-4`
- **Endpoint:** `https://openrouter.ai/api/v1/chat/completions`
- **File:** `supabase/functions/authenticate-sneaker/index.ts` (line 269)

### How to Change AI Model
1. Edit `supabase/functions/authenticate-sneaker/index.ts`
2. Change line 269: `model: "anthropic/claude-sonnet-4"` to desired model
3. Redeploy: `supabase functions deploy authenticate-sneaker`

### Available OpenRouter Models
| Model | OpenRouter ID |
|-------|---------------|
| Claude Sonnet 4 (current) | `anthropic/claude-sonnet-4` |
| Claude Opus 4 | `anthropic/claude-opus-4` |
| GPT-4o | `openai/gpt-4o` |
| Gemini 2.0 Flash | `google/gemini-2.0-flash-001` |

### Supabase Secrets (Current)
- `OPENROUTER_API_KEY` - OpenRouter API access
- `SUPABASE_ANON_KEY` - Public client key
- `SUPABASE_SERVICE_ROLE_KEY` - Server-side key
- `SUPABASE_URL` - Project URL
- `SUPABASE_DB_URL` - Database connection
