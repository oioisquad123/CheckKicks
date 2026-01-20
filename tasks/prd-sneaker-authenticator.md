# PRD: AI-Powered Sneaker Authenticator

## Introduction/Overview

**Auntentic** is an iOS app that uses AI to authenticate sneakers instantly. Users photograph their sneakers from multiple angles, and the app returns a confidence score indicating authenticity likelihood.

### Problem Statement
Counterfeit sneakers plague the secondary market. Existing services (CheckCheck, Legit Check by Ch) rely on human experts, charging ~$6/check with wait times of minutes to hours. Buyers and resellers need a faster, more affordable solution.

### Solution
A fully automated, AI-powered authentication app that delivers results in seconds with a subscription model (~$9.99/month unlimited). Clear disclaimers communicate that results are probabilistic, not guaranteed.

### Target Market
- U.S. sneaker collectors, resellers, and casual buyers
- iOS users (iPhone with camera)
- Popular brands: Nike, Jordan, Adidas Yeezy, New Balance, etc.

---

## Goals

| Goal | Success Metric | Priority |
|------|----------------|----------|
| Instant authentication | Result in < 30 seconds | P0 |
| High accuracy | ≥ 90% correct on test dataset | P0 |
| Simple UX | Complete check in < 2 minutes | P0 |
| Subscription revenue | 500+ subscribers in 6 months | P1 |
| User trust | 4.5+ App Store rating | P1 |

---

## User Stories

### Core User Stories (MVP - Phase 1)

1. **As a buyer**, I want to photograph a sneaker and get an instant authenticity assessment so I can decide whether to purchase.

2. **As a user**, I want clear guidance on which photos to take so the AI has enough information to make an accurate assessment.

3. **As a user**, I want to see a confidence percentage with a clear verdict (Likely Authentic / Likely Fake / Inconclusive) so I understand the result.

4. **As a user**, I want to see a disclaimer that the result is AI-assisted and not guaranteed so I understand the limitations.

5. **As a subscriber**, I want unlimited authentication checks for a monthly fee so I can verify multiple sneakers affordably.

6. **As a new user**, I want to sign in with Apple or email so I can access my subscription across devices.

### Extended User Stories (Phase 2+)

7. **As a returning user**, I want to view my authentication history so I can reference past checks.

8. **As a user**, I want push notifications when my result is ready (if processing takes longer than expected).

9. **As a first-time user**, I want an onboarding tutorial explaining how the app works.

---

## Functional Requirements

### Phase 1: MVP (Weeks 1-4)

#### Authentication & Accounts
| ID | Requirement | Notes |
|----|-------------|-------|
| FR-1.1 | System must support Apple Sign-In | Required by App Store |
| FR-1.2 | System must support Email/Password auth via Supabase | Secondary option |
| FR-1.3 | User session must persist across app launches | Supabase Auth tokens |
| FR-1.4 | System must handle sign-out and account switching | Clear local data |

#### Photo Capture Flow
| ID | Requirement | Notes |
|----|-------------|-------|
| FR-2.1 | App must provide a guided photo capture flow | Step-by-step screens |
| FR-2.2 | Initial capture must request 4 photos: outer side, inner side, size tag, box label | Minimum viable set |
| FR-2.3 | Each step must show visual guidance (overlay/example image) | Help user align shot |
| FR-2.4 | User must be able to retake any photo before submission | Review screen |
| FR-2.5 | System must allow importing photos from gallery | Alternative to camera |
| FR-2.6 | Images must be compressed before upload (max 1MB each) | Performance |

#### AI Analysis
| ID | Requirement | Notes |
|----|-------------|-------|
| FR-3.1 | App must upload images to Supabase Edge Function | Secure HTTPS |
| FR-3.2 | Edge Function must call OpenAI Vision API (GPT-4o) | Cloud processing |
| FR-3.3 | AI must return: verdict, confidence %, key observations | Structured response |
| FR-3.4 | AI may request additional photos if initial set insufficient | Flexible approach |
| FR-3.5 | System must display loading state during analysis | "Analyzing..." |
| FR-3.6 | Analysis must complete in < 60 seconds (target < 30s) | Performance goal |

#### Results Display
| ID | Requirement | Notes |
|----|-------------|-------|
| FR-4.1 | Result screen must show verdict: "Likely Authentic" / "Likely Fake" / "Inconclusive" | Clear labels |
| FR-4.2 | Result screen must show confidence percentage (0-100%) | Numerical clarity |
| FR-4.3 | Result screen must use color coding: green (auth), red (fake), yellow (inconclusive) | Visual feedback |
| FR-4.4 | Result screen must display disclaimer: "This result is AI-assisted and does not guarantee authenticity." | Always visible |
| FR-4.5 | Result screen may show key observations from AI | Optional detail |
| FR-4.6 | User must be able to start a new check from result screen | Flow continuity |

#### Subscription & Paywall
| ID | Requirement | Notes |
|----|-------------|-------|
| FR-5.1 | System must integrate StoreKit 2 for subscriptions | Apple IAP |
| FR-5.2 | Offer monthly subscription at $9.99/month (unlimited checks) | Primary tier |
| FR-5.3 | Non-subscribers get 1 free check, then see paywall | Trial experience |
| FR-5.4 | Paywall must clearly show pricing and value proposition | Conversion focus |
| FR-5.5 | System must verify subscription status before each check | Server-side validation |
| FR-5.6 | System must handle restore purchases | App Store requirement |

#### Error Handling
| ID | Requirement | Notes |
|----|-------------|-------|
| FR-6.1 | App must detect and display "no internet" error | Graceful failure |
| FR-6.2 | App must handle API timeout with retry option | User control |
| FR-6.3 | App must handle poor image quality with retake prompt | Improve accuracy |
| FR-6.4 | App must handle unsupported/unrecognized sneaker model | Inform user |

### Phase 2: Polish (Weeks 5-8)

| ID | Requirement | Notes |
|----|-------------|-------|
| FR-7.1 | System must store authentication history in Supabase | Persistent storage |
| FR-7.2 | User must be able to view past checks with date, result, thumbnail | History screen |
| FR-7.3 | App must include onboarding screens for first-time users | 3-4 screens max |
| FR-7.4 | App must send push notification when result ready (if app backgrounded) | Optional enhancement |
| FR-7.5 | Settings screen with account info, subscription status, sign out | User management |

### Phase 3: Enhancement (Post-launch)

| ID | Requirement | Notes |
|----|-------------|-------|
| FR-8.1 | Support additional subscription tiers (e.g., $4.99 for 5 checks) | Revenue optimization |
| FR-8.2 | Allow user to specify sneaker model before analysis | Improve accuracy |
| FR-8.3 | Provide detailed breakdown of authenticity markers | Educational value |
| FR-8.4 | Share result as image/link | Social proof |

---

## Non-Goals (Out of Scope)

| Explicitly Excluded | Rationale |
|---------------------|-----------|
| Human expert verification | Fully automated AI-only |
| Authenticity certificates or guarantees | Liability concerns |
| Offline mode | Requires cloud AI |
| Android app | iOS-first strategy |
| Non-sneaker items (bags, watches, apparel) | Focus on sneakers |
| Marketplace/trading features | Authentication only |
| Social/community features | Keep it simple |
| On-device ML model | Cloud-only for updates |

---

## Design Considerations

### Visual Identity
- **App Name:** Auntentic (or similar implying authenticity)
- **Theme:** Modern, trustworthy, tech-forward
- **Colors:** 
  - Primary: Deep navy or black (premium feel)
  - Authentic: Green (#22C55E)
  - Fake: Red (#EF4444)
  - Inconclusive: Amber (#F59E0B)
- **Typography:** SF Pro (system) for clarity

### Key Screens

```
1. Splash/Launch
2. Sign In (Apple / Email)
3. Home (Start New Check button, subscription status)
4. Photo Capture (multi-step wizard)
   - Step 1: Outer Side
   - Step 2: Inner Side
   - Step 3: Size Tag
   - Step 4: Box Label
   - Review: All photos grid
5. Loading/Analyzing
6. Result (verdict, confidence, disclaimer)
7. Paywall (for non-subscribers after free check)
8. History (Phase 2)
9. Settings (Phase 2)
```

### UX Guidelines
- **Photo Guidance:** Show semi-transparent overlay of expected shoe position
- **Progress:** "Step 2 of 4" indicator during capture
- **Loading:** Animated spinner with "Analyzing your sneaker..." text
- **Result:** Large verdict text, confidence as circular progress, disclaimer below
- **Accessibility:** VoiceOver labels, Dynamic Type support, color + text for status

### Disclaimer Placement
- Always visible on result screen (not hidden in a tooltip)
- Smaller italic text below the main result
- Example: _"This result is AI-assisted and does not guarantee authenticity. Use additional verification methods for high-value purchases."_

---

## Technical Considerations

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Views     │  │ ViewModels  │  │     Services        │ │
│  │  (SwiftUI)  │◄─┤   (MVVM)    │◄─┤ (Auth, API, Store)  │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Supabase                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    Auth     │  │   Storage   │  │   Edge Functions    │ │
│  │  (Users)    │  │  (Images)   │  │ (OpenAI Proxy)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│                                              │              │
│  ┌─────────────┐                             ▼              │
│  │  Database   │◄────────────────   OpenAI Vision API      │
│  │ (History)   │                                            │
│  └─────────────┘                                            │
└─────────────────────────────────────────────────────────────┘
```

### Tech Stack

| Layer | Technology |
|-------|------------|
| UI | SwiftUI (iOS 17+) |
| Architecture | MVVM + async/await |
| Auth | Supabase Auth (Apple Sign-In, Email) |
| Backend | Supabase Edge Functions (Deno) |
| AI | OpenAI GPT-4o Vision API |
| Storage | Supabase Storage (images) |
| Database | Supabase PostgreSQL (history) |
| Payments | StoreKit 2 |
| Logging | os.Logger |

### Supabase Schema

```sql
-- Users (managed by Supabase Auth)

-- Authentication history
CREATE TABLE authentications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  verdict TEXT NOT NULL, -- 'authentic', 'fake', 'inconclusive'
  confidence INTEGER NOT NULL, -- 0-100
  observations JSONB, -- AI observations array
  image_urls TEXT[], -- Supabase Storage paths
  sneaker_model TEXT -- Detected or user-provided
);

-- Subscription tracking (supplement to StoreKit)
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  status TEXT NOT NULL, -- 'active', 'expired', 'cancelled'
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Free check tracking
CREATE TABLE free_checks (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  checks_used INTEGER DEFAULT 0,
  last_check_at TIMESTAMPTZ
);
```

### Edge Function: Authenticate Sneaker

```typescript
// supabase/functions/authenticate-sneaker/index.ts
// Receives: image URLs from Supabase Storage
// Calls: OpenAI Vision API
// Returns: { verdict, confidence, observations, additionalPhotosNeeded? }
```

### Security Considerations
- **API Keys:** OpenAI key stored in Supabase Edge Function secrets (never in app)
- **Auth Tokens:** Supabase manages JWT tokens securely
- **Image Privacy:** Images stored in user-specific Storage buckets with RLS
- **HTTPS:** All communication encrypted

### Performance Targets
- Image upload: < 5 seconds (4 images, ~4MB total)
- AI analysis: < 20 seconds
- Total flow: < 30 seconds end-to-end

### Dependencies
- Supabase Swift SDK
- StoreKit 2 (native)
- No third-party UI libraries (pure SwiftUI)

---

## Success Metrics

### MVP Success Criteria (Week 4)

| Metric | Target |
|--------|--------|
| Core flow works | Photo → Upload → AI → Result |
| Subscription works | Purchase, verify, paywall |
| Auth works | Apple Sign-In, Email |
| Performance | < 60 seconds total |
| Crash-free | 99%+ stability |

### 6-Month Success Criteria

| Metric | Target |
|--------|--------|
| Downloads | 10,000+ |
| Subscribers | 500+ (5% conversion) |
| MRR | $5,000+ |
| AI Accuracy | 90%+ on test set |
| App Rating | 4.5+ stars |
| Avg Response Time | < 30 seconds |

---

## Open Questions

| # | Question | Owner | Status |
|---|----------|-------|--------|
| 1 | What OpenAI prompt yields best accuracy for sneaker authentication? | Dev | To research |
| 2 | Should we store images permanently for model training (with consent)? | Product | To decide |
| 3 | What's the exact wording for Terms of Service / liability waiver? | Legal | To draft |
| 4 | Which sneaker models to prioritize for testing? (Jordan 1, Yeezy 350, Dunk?) | Product | To decide |
| 5 | Should "Inconclusive" results count against subscription/free tier? | Product | To decide |
| 6 | Pricing: $9.99 unlimited vs tiered options? | Product | Start with $9.99, iterate |

---

## Implementation Phases

### Phase 1: MVP (Weeks 1-4) ✅ CURRENT FOCUS

**Week 1: Foundation**
- [ ] Project setup (Xcode, Supabase project)
- [ ] Supabase Auth integration (Apple Sign-In, Email)
- [ ] Basic app navigation structure
- [ ] Supabase database schema

**Week 2: Core Flow**
- [ ] Photo capture wizard (4 steps with guidance)
- [ ] Image upload to Supabase Storage
- [ ] Edge Function: OpenAI Vision integration
- [ ] Result screen with verdict display

**Week 3: Monetization**
- [ ] StoreKit 2 subscription integration
- [ ] Paywall screen
- [ ] Free check tracking
- [ ] Subscription verification

**Week 4: Polish & Testing**
- [ ] Error handling (network, API failures)
- [ ] Loading states and animations
- [ ] UI polish and accessibility
- [ ] TestFlight beta

### Phase 2: Enhance (Weeks 5-8)
- Authentication history
- Onboarding tutorial
- Push notifications
- Settings screen
- App Store submission

### Phase 3: Scale (Post-launch)
- Analytics integration
- A/B test pricing
- Model improvement with user data
- Additional subscription tiers

---

## Appendix

### Competitor Reference

| Feature | Auntentic (Us) | CheckCheck | Legit Check by Ch |
|---------|----------------|------------|-------------------|
| Method | AI-only | Human experts | Human experts |
| Speed | < 30 seconds | Minutes to hours | Minutes to hours |
| Price | $9.99/mo unlimited | ~$6/check | ~$5-10/check |
| Guarantee | No (disclaimer) | Money-back | Varies |
| Certificate | No | Yes | Yes |

### AI Prompt Strategy (Initial)

```
You are an expert sneaker authenticator. Analyze the provided images of a sneaker and determine its authenticity.

Evaluate:
1. Stitching quality and consistency
2. Logo placement and accuracy
3. Material quality indicators
4. Shape and proportions
5. Label/tag accuracy
6. Box label details

Return a JSON response:
{
  "verdict": "authentic" | "fake" | "inconclusive",
  "confidence": 0-100,
  "observations": ["observation1", "observation2", ...],
  "additionalPhotosNeeded": ["angle1", "angle2"] | null
}

Be conservative: if uncertain, return "inconclusive" rather than a wrong verdict.
```

---

**Document Version:** 1.0  
**Created:** December 25, 2025  
**Last Updated:** December 25, 2025  
**Author:** AI Assistant  
**Status:** Ready for Development

