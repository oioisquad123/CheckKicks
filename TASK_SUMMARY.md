# CheckKicks - Task Summary & Roadmap

**Last Updated:** January 17, 2026
**App Status:** TestFlight live, preparing for App Store submission
**Progress:** 30/35 tasks complete (86%)

---

## Quick Status

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1A: Core MVP | ✅ Complete | 14/14 |
| Phase 1B: Lean Beta | ✅ Complete | 4/4 |
| Phase 1C: TestFlight Upload | ✅ Complete | 2/2 |
| Phase 1D: Monetization | ✅ Complete | 5/5 |
| Phase 1E: TestFlight Distribution | ✅ Complete | 2/2 |
| Phase 1F: Polish | ⏳ Pending | 0/3 |
| Phase 2: Launch | 🔄 In Progress | 3/5 |

---

## Completed Phases

### Phase 1A: Core MVP Foundation ✅
*All foundation work complete - app can authenticate sneakers*

| Task | Description | Status |
|------|-------------|--------|
| 1 | Xcode project + Supabase Swift SDK | ✅ |
| 2 | Supabase configuration (Auth, Storage, DB, Edge Functions) | ✅ |
| 3 | Database schema with RLS policies | ✅ |
| 4 | Storage bucket for sneaker images | ✅ |
| 5 | MVVM architecture + NavigationStack | ✅ |
| 6 | Authentication (Apple Sign-In + Email/OTP) | ✅ |
| 7 | 6-photo capture wizard with guidance overlays | ✅ |
| 8 | Photo review screen with retake option | ✅ |
| 9 | Image upload service with compression | ✅ |
| 10 | Edge Function with Claude Sonnet 4 (via OpenRouter) | ✅ |
| 11 | AI analysis integration with loading states | ✅ |
| 12 | Results screen (Aegis Gold premium UI) | ✅ |
| 13 | Save authentication results to database | ✅ |
| 13.5 | History service integration | ✅ |

### Phase 1B: Lean MVP for Beta ✅
*Essential features for beta testing*

| Task | Description | Status |
|------|-------------|--------|
| 23 | History screen (view past checks) | ✅ |
| 18 | Error handling & network resilience | ✅ |
| 19 | Loading states & animations | ✅ |
| 24 | Onboarding tutorial (4 screens) | ✅ |

### Phase 1C: TestFlight Upload ✅
*Build uploaded to App Store Connect*

| Task | Description | Status |
|------|-------------|--------|
| 21.5 | App icon (CheckKicks premium design) | ✅ |
| 21A | Build uploaded to App Store Connect | ✅ |

---

## Upcoming Phases

### Phase 1D: Monetization ✅
*Credit-based payment system implemented*

| Task | Description | Status |
|------|-------------|--------|
| 14 | StoreKit 2 Consumables (4 credit packs) | ✅ |
| 15 | Free Check Tracking (3 free credits) | ✅ |
| 16 | Purchase Screen (Aegis Gold design) | ✅ |
| 17 | Credits Sync to Supabase | ✅ |
| 26 | Settings Screen (Account, Credits, History) | ✅ |

**Credit Tiers:**
| Tier | Credits | Price | Per Check |
|------|---------|-------|-----------|
| Free | 3 | $0 | Free |
| Basic | 10 | $6.99 | $0.70 |
| Standard | 25 | $14.99 | $0.60 |
| Pro | 60 | $29.99 | $0.50 |
| Business | 150 | $59.99 | $0.40 |

**Implementation Order:**
1. Task 14: Create `CreditManager` service (StoreKit 2 consumables)
2. Task 15: Add free check enforcement (3 checks)
3. Task 16: Build credit purchase UI
4. Task 17: Sync credits to Supabase database
5. Task 26: Build settings screen with credit balance

### Phase 1E: TestFlight Distribution ✅
*TestFlight beta testing is now live!*

| Step | Description | Status |
|------|-------------|--------|
| 0 | Re-upload build with app icon | ✅ Build 2 uploaded (Jan 17) |
| 1 | Complete Export Compliance questions | ✅ Done |
| 2 | Add Test Information (beta description) | ✅ Done |
| 3 | Create Internal Tester group | ✅ "Core Team" created |
| 4 | Add team members by Apple ID | ✅ Testers added |
| 5 | Enable build for testing | ✅ Build 2 enabled |
| 6 | Distribute to testers | ✅ Testers installed app |
| 7 | **Privacy Policy & Terms of Service** | ✅ Created (`/docs/`) |

**Status:** Beta testers are now testing the app via TestFlight!

### Phase 1F: Polish (Optional)
*Nice-to-have improvements*

| Task | Description | Priority |
|------|-------------|----------|
| 20 | Accessibility/VoiceOver support | LOW |
| 22 | Handle AI request for additional photos | LOW |
| 20.5 | Performance testing & optimization | LOW |

### Phase 2: Launch 🔄
*Final steps for App Store submission*

| Task | Description | Status |
|------|-------------|--------|
| **27.5** | **Terms of Service & Privacy Policy** | ✅ Created (`/docs/`) |
| **NEW** | **Privacy Manifest (PrivacyInfo.xcprivacy)** | ✅ Created |
| **NEW** | **GitHub Pages HTML files** | ✅ Created (`/docs/github-pages/`) |
| 25 | Push notifications | ⏳ Optional |
| - | Host legal docs on GitHub Pages | ⏳ Manual step |
| - | App Store screenshots | ⏳ Manual step |
| - | Configure App Store metadata | ⏳ Manual step |
| - | Create demo account for reviewers | ⏳ Manual step |
| **27** | **App Store Submission** | ⏳ Final Step |

**Files Created for App Store:**
- `Auntentic_AI/Auntentic_AI/PrivacyInfo.xcprivacy` - Privacy Manifest
- `docs/github-pages/index.html` - Landing page
- `docs/github-pages/privacy.html` - Privacy Policy (HTML)
- `docs/github-pages/terms.html` - Terms of Service (HTML)

---

## What to Do Now

### ✅ Completed: Legal Documents (Jan 17, 2026)

- ✅ `/docs/PRIVACY_POLICY.md` - Privacy policy for App Store
- ✅ `/docs/TERMS_OF_SERVICE.md` - Terms of service for App Store

### 🔄 In Progress: TestFlight Distribution (Phase 1E)

**Step 1: Re-upload Build (Xcode)**
Current build is missing the app icon. Need to upload fresh:
1. Open Xcode → `Auntentic_AI.xcodeproj`
2. Select **Product → Destination → Any iOS Device**
3. Select **Product → Archive**
4. In Organizer, click **Distribute App → App Store Connect → Upload**
5. Wait 5-15 minutes for processing

**Step 2: Complete TestFlight Setup (App Store Connect)**
1. Go to App Store Connect → CheckKicks → TestFlight
2. Click on new build, answer Export Compliance (Yes → Exempt with HTTPS)
3. Add Test Information (beta description, feedback email)
4. Create "Core Team" internal tester group
5. Add 2-5 testers by Apple ID
6. Enable build for testing

**Step 3: Test via TestFlight**
1. Testers receive email invitation
2. Download TestFlight app from App Store
3. Accept invitation and install CheckKicks
4. Test all features (auth, photos, AI, purchases)

### Next: Host Legal Documents

Before App Store submission, host legal docs at:
- https://checkkicks.app/privacy
- https://checkkicks.app/terms

---

## Technical Reference

### AI Backend
- **Provider:** OpenRouter (openrouter.ai)
- **Model:** `anthropic/claude-sonnet-4`
- **Edge Function:** `supabase/functions/authenticate-sneaker/index.ts`
- **How to change model:** Edit line 269, redeploy with `supabase functions deploy authenticate-sneaker`

### Database Tables
| Table | Purpose |
|-------|---------|
| `authentications` | Store check results (user_id, verdict, confidence, observations, image_urls) |
| `user_credits` | Track credit balance (user_id, credits, last_purchase_at) |
| `credit_transactions` | Purchase history (user_id, product_id, credits_added, amount, purchased_at) |

### Supabase Secrets
- `OPENROUTER_API_KEY` - AI API access
- `SUPABASE_ANON_KEY` - Public client key
- `SUPABASE_SERVICE_ROLE_KEY` - Server-side key

### Key Files
| Component | Path |
|-----------|------|
| App Entry | `Auntentic_AI/App/Auntentic_AIApp.swift` |
| Navigation | `Auntentic_AI/ViewModels/NavigationCoordinator.swift` |
| AI Service | `Auntentic_AI/Services/SneakerAuthenticationService.swift` |
| Design System | `Auntentic_AI/Shared/Theme/AegisDesignSystem.swift` |
| Edge Function | `supabase/functions/authenticate-sneaker/index.ts` |
| PRD | `tasks/prd-sneaker-authenticator.md` |

---

## Free vs Paid Features

| Feature | Free (3 credits) | Paid (Credit Packs) |
|---------|------------------|---------------------|
| Authentication checks | 3 lifetime | Buy more as needed |
| AI confidence score | ✅ | ✅ |
| Basic result | ✅ | ✅ |
| Ads shown | ✅ | ❌ |
| **Future:** Detailed breakdown | ❌ | ✅ |
| **Future:** History saved | ❌ | ✅ |
| **Future:** Shareable result | ❌ | ✅ |

**Pricing:**
| Tier | Credits | Price | Per Check |
|------|---------|-------|-----------|
| Free | 3 | $0 | - |
| Basic | 10 | $6.99 | $0.70 |
| Standard | 25 | $14.99 | $0.60 |
| Pro | 60 | $29.99 | $0.50 |
| Business | 150 | $59.99 | $0.40 |

---

## Milestones

- **Dec 25, 2025:** Project started
- **Dec 31, 2025:** Core MVP complete (Tasks 1-13)
- **Jan 1, 2026:** TestFlight build uploaded (missing app icon)
- **Jan 7, 2026:** Migrated to OpenRouter (Claude Sonnet 4)
- **Jan 9, 2026:** Task summary consolidated
- **Jan 11, 2026:** Monetization system complete (Tasks 14-17, 26)
- **Jan 17, 2026:** Privacy Policy & Terms of Service created
- **Jan 17, 2026:** Google Sign-In & cellular upload fixes
- **Jan 17, 2026:** TestFlight distribution live (Phase 1E complete)
- **TBD:** App Store launch

---

*This document replaces TASK_EXECUTION_ORDER.md and TASK_REVIEW_AND_RECOMMENDATIONS.md*
