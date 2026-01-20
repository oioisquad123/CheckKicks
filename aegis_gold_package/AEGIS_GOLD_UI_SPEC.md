# Aegis Gold (Dark Navy + Metallic Gold) — UI Spec for CheckKicks / “Auntentic”

**Goal:** Redesign every screen to match the **Aegis Gold** theme: premium dark-navy surfaces + metallic gold accents + subtle glow.  
**Platform:** iOS 17+ / SwiftUI  
**Principles:** Trustworthy, security-forward, premium, minimal, readable.

---

## 1) Design Tokens (Source of Truth)

### Colors
- Background: **aegisNavy** `#0D1226`
- Background (alt): **aegisNavyLight** `#1A1F38`
- Elevated: **aegisNavyElevated** `#252B45`

- Gold Light: **aegisGoldLight** `#FFF299`
- Gold Mid: **aegisGoldMid** `#FFD700`
- Gold Dark: **aegisGoldDark** `#DAA520`

- Text Primary: **aegisWhite** `white @ 95%`
- Text Secondary: **aegisGray** `white @ 60%`
- Text Muted: **aegisMuted** `white @ 40%`
- Ink on Gold: **aegisInk** `black @ 85%`

- Success: **aegisSuccess** `#22C55E`
- Warning: **aegisWarning** `#F59E0B`
- Error: **aegisError** `#EF4444`
- Info: **aegisInfo** `#3B82F6`

### Gradients
- Navy background: `aegisNavyLight → aegisNavy` (top → bottom)
- Gold primary: `aegisGoldLight → aegisGoldMid → aegisGoldDark` (topLeading → bottomTrailing)

### Radii & Spacing
- Screen padding: 24
- Card padding: 20
- Card radius: 20 (continuous)
- Primary button height: 56
- Primary button radius: 16 (continuous)
- Secondary button height: 50
- Secondary button radius: 14
- Min tap target: 44
- Section spacing: 16–24

### Shadows & Glow
- Card shadow: black @ 30%, radius 8, y: 4
- Primary CTA shadow: gold @ 40%, radius 12, y: 6
- Subtle “shine”: use **very low opacity** gold strokes (10–30%) + mild blur.

### Typography (SF Pro / System)
- Hero: 44 Bold
- Screen title: 34 Bold
- Card title: 20 Bold
- Body: 15–17 Medium
- Caption: 12–13 Medium
- Micro: 11 Semibold

---

## 2) Reusable Components (must be used everywhere)

### AegisBackground
- Always use `withAegisBackground(showWatermark:)` on full screens
- Watermark: `shield.fill` @ 2–3% opacity (only on Home/Auth)

### Buttons
- `AegisPrimaryButton` = gold gradient + ink text + press scale effect (0.96)
- `AegisSecondaryButton` = navy elevated + gold gradient stroke
- `AegisGhostButton` = transparent + gold text for tertiary actions

### Surfaces
- `AegisCard` = navyLight, gold stroke @ ~30%, soft shadow
- `AegisStatCard` = icon circle + value + label

### Indicators
- Step pill: gold stroke capsule, filled when active
- Progress bar: gold gradient foreground on navyElevated background

---

## 3) Screen-by-Screen Redesign (Layouts + Behavior)

### Screen: Auth (Login) — `AuthView`
**Purpose:** Trust + premium feel.
- Background: navy gradient + shield watermark @ 3%
- Hero: shield icon in gold gradient + 2–3 concentric rings
- Buttons:
  - Primary: “Sign in with Apple”
  - Secondary: “Sign in with Email”
- Footer: Terms & Privacy caption in muted text

### Screen: Home (Dashboard) — `HomeView`
**Purpose:** Single clear CTA.
- Top hero: app shield mark + title + tagline
- Main action card:
  - camera icon circle
  - “Start Authentication”
  - “Take 6 photos to verify your sneakers”
  - Primary CTA: “Take Photos”
- Tips card (optional): 3 bullet rows with icons (camera/light/close-up)
- Quick stats: History / Free Check
- Always show disclaimer at bottom (micro):  
  “This result is AI-assisted and does not guarantee authenticity.”

### Screen: Capture Wizard (Multi-step) — `PhotoCaptureWizardView`
**Purpose:** Guide user through required angles with zero confusion.
- Header: “Capture Photos” (34 Bold)
- Stepper row: 6 capsules (gold filled = done, gold stroke = current, muted = future)
- Current step card:
  - Step name (e.g., “Outer Side”, “Heel Logo”)
  - Short instruction + example notes
  - “Tips” mini card (AegisCard showGoldBorder: false + gold stroke 20%)
- Actions:
  - Primary: “Take Photo”
  - Secondary: “Import from Gallery”
  - Ghost: “Skip (Not Recommended)” (only if product wants it)

### Screen: Camera Capture (Overlay) — `PhotoCaptureStepView` + `GuidanceOverlayView`
**Purpose:** Make it hard to capture bad photos.
- Live camera preview full screen
- Overlay elements:
  - Top title: step name
  - Framing guide: rounded rectangle / silhouette guide in **gold stroke @ 25%**
  - Quality checks (real-time): blur, exposure, distance → show small pill warnings (warning color)
  - Bottom sheet (collapsed):
    - “Hold steady • Use natural light”
    - Primary capture shutter button (gold ring + center)
- After capture: quick review modal (photo + retake/keep)

### Screen: Photo Review (Before Analyze) — `PhotoReviewView`
**Purpose:** Confirm completeness and quality.
- Grid of 6 photo cards (2 columns)
  - Each card: navyLight + gold stroke 20%
  - Status: checkmark (success) or warning badge
- Primary: “Authenticate Sneakers” (sparkles icon)
- Secondary: “Retake Missing”
- Note: show disclaimer before submission

### Screen: Processing — `ProcessingView` (new)
**Purpose:** Premium “scan” moment.
- Center: Lottie “scan” animation (or AegisSpinner if no Lottie)
- Status text cycles: “Analyzing stitching…”, “Checking logo proportions…”, etc.
- Show tip: “This takes ~10–20 seconds” (optional)
- No back navigation while uploading (unless you want cancellation)

### Screen: Results — `ResultsView`
**Purpose:** Confidence and transparency.
- Confidence ring (existing `AegisResultBadge`)
- Verdict copy rules:
  - Never claim 100%
  - Use “Likely Authentic / Likely Fake / Inconclusive”
- Disclaimer card MUST include:
  “This result is AI-assisted and does not guarantee authenticity.”
- Observations list in `AegisCard`
- Primary: “New Check”
- Ghost: “Done”

### Screen: History — `HistoryView`
**Purpose:** Fast browsing of past checks.
- Replace system `List` look with custom scroll + cards OR heavily styled list rows.
- Each row card:
  - Thumbnail left
  - Model/name + date
  - Verdict badge (success/warning/error) + small confidence percent
  - Gold stroke 15–25% + subtle shadow
- Empty state:
  - Shield watermark
  - “No checks yet”
  - CTA “Start Authentication”

### Screen: Settings — `SettingsView`
**Purpose:** Trust + legal.
- Use Aegis background + grouped cards
- Sections: Account, Privacy, Data Retention, Support, Legal
- Keep it simple and readable

---

## 4) Capture Steps (Exact 6 Angles)
1. Full Shoe (Outer side)
2. Full Shoe (Inner side)
3. Heel logo
4. Outsole
5. Insole (logo/print)
6. Size tag / serial label

Each step includes:
- 1-line instruction
- 2 bullet tips
- “Common mistakes” micro text

---

## 5) AI Disclaimer (Must show on Results + before submission)
> “This result is AI-assisted and does not guarantee authenticity.”

Optional extended text:
- “For high-value items, consider expert verification.”

---

## 6) Asset Notes
- Icon usage: your gold shield app icon should be used on Auth + Home hero.
- Avoid bright blues/purples; keep everything navy/gold.
- Keep glow subtle: less is more.
