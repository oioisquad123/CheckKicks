# Cursor/Claude Implementation Brief — Apply Aegis Gold Theme Everywhere

Use this file as the “single source prompt” for Cursor / Claude Code.

---

## Objective
Refactor and redesign **all** CheckKicks SwiftUI screens to match the **Aegis Gold** theme:
- Dark navy gradient backgrounds
- Metallic gold accents + gradient
- Glassy navy cards with subtle gold borders
- Premium motion (subtle) and consistent typography

**Important:** The app is AI-assisted. Never claim guaranteed authenticity. Always show disclaimer:
“This result is AI-assisted and does not guarantee authenticity.”

---

## Current Files (From Code Export)
- `AegisDesignSystem.swift` (keep, extend carefully)
- `AuthView.swift` (already close)
- `HomeView.swift` (already close; fix copy + add tips card if desired)
- `ResultsView.swift` (already close; ensure disclaimer language)
- `PhotoCaptureStepView.swift` (HIGH: needs Aegis)
- `PhotoReviewView.swift` (HIGH: needs Aegis)
- `HistoryView.swift` (MEDIUM: partial)

---

## Work Plan (Do in this order)
1) **Design System**
   - Add: `AegisGhostButton`, `AegisSectionHeader`, `AegisPillBadge`, `AegisStepIndicator`
   - Add: press animation for primary/secondary buttons (scale to 0.96)
   - Ensure `withAegisBackground(showWatermark:)` is used everywhere

2) **Capture Flow**
   - Create/Update `PhotoCaptureWizardView`:
     - 6-step pill indicator
     - Step card with instructions and tips
     - Routes to camera overlay per step
   - Redesign `PhotoCaptureStepView`:
     - Navy gradient background behind camera preview
     - Gold framing guide overlay
     - Bottom controls styled in Aegis (gold shutter ring)
     - Real-time warnings as pill badges (warning color)
   - Redesign `PhotoReviewView`:
     - 6-photo grid cards with gold strokes
     - Primary CTA “Authenticate Sneakers”
     - Retake flows

3) **Processing Screen**
   - Add new `ProcessingView` with AegisSpinner or Lottie if available
   - Status text cycling (3–5 messages)
   - Disable back while processing/uploading

4) **History Screen**
   - Replace default list styling with Aegis cards or style rows heavily
   - Add empty state with shield watermark + CTA

5) **Copy + Consistency**
   - Fix typos (“Auntentic” → confirm desired spelling; if brand is “CheckKicks”, align)
   - Ensure consistent icon usage and spacing
   - Ensure disclaimer appears (pre-submit + results)

---

## Acceptance Criteria (Visual)
- No purple/bright blue gradients anywhere
- Cards are navyLight with subtle gold borders (15–30% opacity)
- Primary CTAs are gold gradient with ink text and gentle glow shadow
- All screens use `withAegisBackground()`
- Capture overlay feels premium and easy to follow

---

## Screens to Implement (Deliverables)
- AuthView (final polish)
- HomeView (final polish + tips)
- PhotoCaptureWizardView (new/updated)
- PhotoCaptureStepView (redesigned overlay)
- GuidanceOverlayView (redesigned)
- PhotoReviewView (redesigned)
- ProcessingView (new)
- ResultsView (final)
- HistoryView (redesigned)
- SettingsView (optional but recommended)

---

## “Image Mockup” Prompts (Use with Image Generator)
Use these prompts to generate screen mockups in the same visual style as the app icon.

### 1) Capture Wizard Screen
“iPhone app UI, dark navy gradient background, metallic gold accents, premium security style, header ‘Capture Photos’, 6-step gold capsule progress indicator, large card showing step ‘Heel Logo’ with tips, two buttons: gold gradient ‘Take Photo’ and navy outlined ‘Import from Gallery’, subtle shield watermark, realistic iOS status bar, clean modern spacing, no cartoon style.”

### 2) Camera Overlay Screen
“iPhone camera capture UI for sneaker authentication, live camera preview blurred placeholder, gold stroke framing guide, top title ‘Outsole’, pill warnings for ‘Low light’ and ‘Hold steady’, bottom shutter button with gold ring, secondary ‘Gallery’ button, dark navy translucent bottom sheet, premium metallic gold accents, realistic iOS UI.”

### 3) Photo Review Screen
“iPhone UI, dark navy gradient, gold accents, grid of 6 photo thumbnails in navy cards with subtle gold borders, status badges, primary gold gradient button ‘Authenticate Sneakers’, secondary navy outlined button ‘Retake Missing’, micro disclaimer text at bottom, premium look.”

### 4) Processing Screen
“iPhone UI, dark navy gradient, gold spinner or scanning animation in center, text ‘Analyzing stitching…’, subtle glow, premium security aesthetic.”

### 5) Results Screen
“iPhone UI, dark navy gradient, confidence ring 78%, verdict ‘Likely Authentic’, gold accents, disclaimer card, observation list in navy cards with gold borders, primary button ‘New Check’, ghost ‘Done’.”

### 6) History Screen
“iPhone UI, dark navy gradient, list of authentication history as cards with thumbnails, verdict badges, confidence %, gold border strokes, empty state variant with shield watermark and CTA.”

---
