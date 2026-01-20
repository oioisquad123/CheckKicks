# CheckKicks iOS App - Complete Design Export
## Aegis Gold Design System

**Last Updated:** January 2, 2026
**Platform:** iOS 17+ / SwiftUI
**Design Theme:** Premium Dark Mode with Metallic Gold Accents

---

## Table of Contents
1. [Color Palette](#1-color-palette)
2. [Typography](#2-typography)
3. [Components](#3-components)
4. [Screen-by-Screen Designs](#4-screen-by-screen-designs)
5. [Screens Needing Design Updates](#5-screens-needing-design-updates)

---

## 1. Color Palette

### Primary Brand Colors (Navy Background)
| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| aegisNavy | #0D1226 | rgb(13, 18, 38) | Main background |
| aegisNavyLight | #1A1F38 | rgb(26, 31, 56) | Cards, elevated surfaces |
| aegisNavyElevated | #252B45 | rgb(37, 43, 69) | Subtle elevation, inputs |

### Gold Gradient Colors (Primary Actions)
| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| aegisGoldLight | #FFF299 | rgb(255, 242, 153) | Gradient highlight |
| aegisGoldMid | #FFD700 | rgb(255, 215, 0) | Primary gold, icons |
| aegisGoldDark | #DAA520 | rgb(218, 165, 32) | Gradient shadow |

### Functional Colors (Text)
| Name | Value | Usage |
|------|-------|-------|
| aegisInk | black @ 85% | Text on gold backgrounds |
| aegisWhite | white @ 95% | Primary text on navy |
| aegisGray | white @ 60% | Secondary text |
| aegisMuted | white @ 40% | Disabled/placeholder text |

### Semantic Colors (Status)
| Name | Hex | Usage |
|------|-----|-------|
| aegisSuccess | #22C55E | Authentic verdict, success states |
| aegisWarning | #F59E0B | Inconclusive verdict, warnings |
| aegisError | #EF4444 | Fake verdict, errors |
| aegisInfo | #3B82F6 | Information, tips |

---

## 2. Typography

**Font Family:** SF Pro (System)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Hero Title | 44pt | Bold | Onboarding app name |
| Screen Title | 34pt | Bold | Page headers |
| Card Title | 20pt | Bold | Section headers |
| Button | 17pt | Bold | Primary buttons |
| Body | 15-17pt | Medium | Main content |
| Caption | 12-13pt | Medium | Labels, metadata |
| Micro | 11pt | Semibold | Badges, tags |

---

## 3. Components

### AegisPrimaryButton
- **Height:** 56pt
- **Corner Radius:** 16pt (continuous)
- **Background:** Gold gradient (topLeading → bottomTrailing)
- **Text Color:** aegisInk (black @ 85%)
- **Shadow:** aegisGoldMid @ 40%, radius 12, y: 6
- **Press Effect:** Scale to 0.96 with spring animation

```swift
struct AegisPrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(LinearGradient.aegisGoldGradient)
            .foregroundStyle(Color.aegisInk)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .aegisGoldMid.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }
}
```

### AegisSecondaryButton
- **Height:** 50pt
- **Corner Radius:** 14pt
- **Background:** aegisNavyElevated
- **Border:** Gold gradient @ 50% opacity, 1.5pt
- **Text Color:** aegisGoldMid

### AegisGhostButton
- **Background:** Transparent
- **Text Color:** aegisGoldMid
- **Padding:** 12pt vertical

### AegisCard
- **Padding:** 20pt
- **Corner Radius:** 20pt (continuous)
- **Background:** aegisNavyLight
- **Border:** Gold gradient @ 30% opacity, 1pt
- **Shadow:** black @ 30%, radius 8, y: 4

### AegisStatCard
- **Icon Circle:** 50pt, aegisGoldMid @ 15%
- **Value Text:** 28pt Bold, aegisWhite
- **Label Text:** 13pt Medium, aegisGray

### AegisSpinner
- **Size:** 44pt
- **Stroke:** 4pt, gold gradient
- **Animation:** Linear rotation, 1 second loop

---

## 4. Screen-by-Screen Designs

### Screen 1: Onboarding (4 pages)

#### Page 1 - Welcome
- **Background:** Navy gradient (aegisNavyLight → aegisNavy)
- **Hero Element:** Shield icon with 3 concentric gold rings
  - Ring sizes: 180pt, 220pt, 260pt
  - Ring animation: Scale 0.8 → 1.0 with spring
- **Title:** "CheckKicks" 44pt Bold, aegisWhite
- **Subtitle:** "AI-Powered Sneaker Authentication" 18pt Medium, aegisGray
- **Page Indicator:** Capsule pills, active = aegisGoldMid (32pt wide), inactive = aegisGray @ 40% (8pt wide)

#### Page 2 - How It Works
- **Header:** "How It Works" 34pt Bold
- **3 Step Cards:**
  - Icon circle: 60pt, aegisNavyLight with gold border
  - Step number on right: 20pt Bold, aegisGoldMid @ 40%
  - Card: aegisNavyLight, 16pt corner radius, gold border @ 20%

#### Page 3 - Instant Results
- **Confidence Ring:** 180pt diameter
  - Background ring: aegisNavyElevated, 12pt stroke
  - Progress ring: aegisSuccess, 12pt stroke, rounded caps
  - Animation: 0 → 87% over 1.5 seconds
- **Verdict Badge:** aegisSuccess background, aegisInk text, 12pt corner radius

#### Page 4 - Get Started
- **Gift Icon:** 120pt gold gradient circle with pulsing rings
- **Text:** "1 Free Check" 40pt Bold, aegisGoldMid
- **CTA Button:** Full width gold gradient, "Get Started" with arrow icon

---

### Screen 2: AuthView (Login)

- **Background:** Navy gradient with shield watermark @ 3% opacity
- **Logo Section:**
  - Shield icon circle: 120pt
  - 3 outer rings: 140pt, 170pt, 200pt
  - Ring opacity: 15%, 11%, 7%
- **Buttons:**
  - "Sign in with Apple" - AegisPrimaryButton with apple.logo icon
  - "Sign in with Email" - AegisSecondaryButton with envelope.fill icon
- **Disclaimer:** 12pt aegisMuted, bottom padding 32pt

---

### Screen 3: HomeView (Dashboard)

- **Background:** Navy gradient with shield watermark @ 2%
- **Header:**
  - Shield icon with double glow circles (70pt, 90pt)
  - App name: "Auntentic" 32pt Bold
  - Tagline: 15pt Medium, aegisGray
- **Main Action Card (AegisCard):**
  - Camera icon: 80pt circle, aegisGoldMid @ 15%
  - Title: "Start Authentication" 20pt Bold
  - Subtitle: "Take 6 photos to verify your sneakers"
  - Button: "Take Photos" AegisPrimaryButton
  - Offline state: Gray background, "No Connection" text
- **Stats Section:**
  - Two AegisStatCards side by side
  - History: clock.arrow.circlepath icon, count value
  - Free Check: star.fill icon, "1" value
- **Toolbar:** Settings gear icon, aegisGoldMid

---

### Screen 4: ResultsView

- **Background:** Navy gradient
- **Confidence Ring (AegisResultBadge):**
  - Size: 180pt
  - Background ring: aegisNavyElevated, 12pt
  - Progress ring: Verdict color, 12pt, animated
  - Center: Verdict icon + percentage + "Confidence" label
- **Verdict Text:** 24pt Bold, verdict color
- **Disclaimer Card:**
  - Warning icon: aegisWarning
  - Border: aegisWarning @ 40%
  - Text: 14pt Medium, aegisGray
- **Observations Card (AegisCard):**
  - Expandable header with chevron
  - Each observation: Icon + text
  - Icons cycle: checkmark.circle.fill, eye.fill, magnifyingglass, sparkle, doc.text.magnifyingglass, star.fill
- **Action Buttons:**
  - "New Check" - AegisPrimaryButton with camera.fill
  - "Done" - AegisGhostButton with house.fill

---

### Screen 5: HistoryView

**CURRENT STATE (needs Aegis update):**
- Uses system List styling
- Verdict colors use Aegis semantic colors

**DESIGN NEEDED:**
- Navy gradient background
- Gold-bordered list rows
- Verdict badges with glow effect
- Empty state with gold accents

---

### Screen 6: PhotoCaptureStepView

**CURRENT STATE (needs Aegis update):**
- Purple gradient background
- White buttons

**DESIGN NEEDED:**
- Navy gradient background
- Gold step indicator
- AegisPrimaryButton for "Take Photo"
- AegisSecondaryButton for "Import from Gallery"
- Gold-bordered tip cards

---

### Screen 7: PhotoReviewView

**CURRENT STATE (needs Aegis update):**
- System gray background
- Blue action button

**DESIGN NEEDED:**
- Navy gradient background
- Gold-bordered photo cards
- AegisPrimaryButton for "Authenticate Sneakers"
- Gold progress bar during upload

---

## 5. Screens Needing Design Updates

| Screen | File | Priority | Status |
|--------|------|----------|--------|
| PhotoCaptureStepView | Views/PhotoCapture/PhotoCaptureStepView.swift | HIGH | Needs Aegis |
| PhotoCaptureWizardView | Views/PhotoCapture/PhotoCaptureWizardView.swift | HIGH | Needs Aegis |
| PhotoReviewView | Views/PhotoCapture/PhotoReviewView.swift | HIGH | Needs Aegis |
| HistoryView | Views/History/HistoryView.swift | MEDIUM | Partial Aegis |
| GuidanceOverlayView | Views/PhotoCapture/GuidanceOverlayView.swift | MEDIUM | Needs Aegis |
| EmailSignInView | Views/Auth/EmailSignInView.swift | LOW | Needs check |

---

## Design Tokens Summary

```
COLORS:
Background:     #0D1226
Card:           #1A1F38
Elevated:       #252B45
Gold Light:     #FFF299
Gold Mid:       #FFD700
Gold Dark:      #DAA520
Success:        #22C55E
Error:          #EF4444
Warning:        #F59E0B
Info:           #3B82F6

DIMENSIONS:
Button Height:          56pt
Card Corner Radius:     20pt
Button Corner Radius:   16pt
Card Padding:           20pt
Touch Target Min:       44pt
Icon Size (Large):      36pt
Icon Size (Medium):     22pt
Icon Size (Small):      16pt

SHADOWS:
Card:   black @ 30%, radius 8, y: 4
Button: gold @ 40%, radius 12, y: 6

ANIMATIONS:
Spring Response:    0.3-0.6 seconds
Spring Damping:     0.6-0.8
Linear Duration:    1.0 second (spinner)
```

---

## SwiftUI Gradient Definitions

```swift
// Gold Gradient (Primary)
LinearGradient(
    colors: [.aegisGoldLight, .aegisGoldMid, .aegisGoldDark],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// Navy Gradient (Background)
LinearGradient(
    colors: [.aegisNavyLight, .aegisNavy],
    startPoint: .top,
    endPoint: .bottom
)
```

---

**End of Design Export**
