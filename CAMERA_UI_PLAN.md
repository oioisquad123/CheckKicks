# Camera UI Redesign - Legit App Style

## Overview
Redesign the photo capture camera interface to match the "Legit app" style with:
1. Reference card (top-right) showing photo type and example image
2. Silhouette overlay showing exact shoe positioning
3. Instruction banner with guidance text
4. Bottom photo progress thumbnails
5. Camera controls (capture, album, flashlight)

---

## Current vs Target UI

### Current Implementation
- Basic camera preview
- Simple guidance overlay
- Photo step indicator text
- Capture button

### Target Implementation (Legit Style)
```
┌─────────────────────────────────────┐
│ CANCEL      Required         SAVE   │ ← Header bar
├─────────────────────────────────────┤
│                      ┌─────────┐    │
│                      │ REF IMG │    │ ← Reference card (top-right)
│                      │ "Outer  │    │
│                      │  Side"  │    │
│                      └─────────┘    │
│                                     │
│         ╭─────────────╮             │
│        ╱               ╲            │ ← Silhouette overlay
│       │   SHOE SHAPE   │            │    (positioned for each angle)
│        ╲               ╱            │
│         ╰─────────────╯             │
│                                     │
├─────────────────────────────────────┤
│  "Position the outer side..."       │ ← Instruction banner (pink/red)
├─────────────────────────────────────┤
│ [□] [□] [□] [□] [□] [□]            │ ← Photo progress thumbnails
│ Side Inner Sole Heel Label Box      │
├─────────────────────────────────────┤
│  📷     ⚪     🔦                   │ ← Controls: Album, Capture, Flash
└─────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Create Silhouette Assets
Create 6 silhouette images for each photo angle:

| Step | Silhouette Name | Shape Description |
|------|-----------------|-------------------|
| 1 | `silhouette_outer_side.png` | Full shoe profile facing right |
| 2 | `silhouette_inner_side.png` | Full shoe profile facing left |
| 3 | `silhouette_sole.png` | Shoe sole/bottom view |
| 4 | `silhouette_heel.png` | Back of shoe (heel view) |
| 5 | `silhouette_tongue.png` | Tongue/label rectangle |
| 6 | `silhouette_box.png` | Rectangle for box label |

**Implementation:** Create as SwiftUI Shape drawings or use semi-transparent PNG assets

### Step 2: Create Reference Images
Add 6 reference images showing ideal photo examples:

| Step | Reference Image | Content |
|------|-----------------|---------|
| 1 | `ref_outer_side` | Example outer side photo |
| 2 | `ref_inner_side` | Example inner side photo |
| 3 | `ref_sole` | Example sole photo |
| 4 | `ref_heel` | Example heel photo |
| 5 | `ref_tongue` | Example tongue/label photo |
| 6 | `ref_sizetag` | Example size tag photo |

### Step 3: Update PhotoCaptureStep Model
```swift
struct PhotoCaptureStep {
    let id: Int
    let title: String
    let instruction: String
    let silhouetteImage: String      // NEW: silhouette asset name
    let referenceImage: String       // NEW: reference photo asset
    let iconName: String             // For bottom thumbnail icons
}
```

### Step 4: Create New UI Components

#### 4a. ReferenceCardView (Top-Right)
```swift
struct ReferenceCardView: View {
    let step: PhotoCaptureStep

    var body: some View {
        VStack(spacing: 4) {
            Image(step.referenceImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)

            Text(step.title)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
    }
}
```

#### 4b. SilhouetteOverlayView (Center)
```swift
struct SilhouetteOverlayView: View {
    let step: PhotoCaptureStep

    var body: some View {
        Image(step.silhouetteImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .opacity(0.4)
            .frame(maxWidth: 280, maxHeight: 350)
    }
}
```

#### 4c. InstructionBannerView
```swift
struct InstructionBannerView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.85))
    }
}
```

#### 4d. PhotoProgressBar (Bottom Thumbnails)
```swift
struct PhotoProgressBar: View {
    let steps: [PhotoCaptureStep]
    let currentStepIndex: Int
    let capturedPhotos: [Int: UIImage]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(steps.indices, id: \.self) { index in
                PhotoProgressItem(
                    step: steps[index],
                    isCurrent: index == currentStepIndex,
                    isCompleted: capturedPhotos[index] != nil,
                    capturedImage: capturedPhotos[index]
                )
            }
        }
        .padding(.horizontal)
    }
}

struct PhotoProgressItem: View {
    let step: PhotoCaptureStep
    let isCurrent: Bool
    let isCompleted: Bool
    let capturedImage: UIImage?

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)

                    Image(systemName: step.iconName)
                        .foregroundColor(isCurrent ? .white : .gray)
                }

                // Current step indicator
                if isCurrent {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 50, height: 50)
                }

                // Checkmark for completed
                if isCompleted {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .background(Color.white.clipShape(Circle()))
                        }
                        Spacer()
                    }
                    .frame(width: 50, height: 50)
                }
            }

            Text(step.shortTitle)
                .font(.system(size: 9))
                .foregroundColor(isCurrent ? .white : .gray)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}
```

### Step 5: Update Camera View Layout

Update `AegisAdvancedCameraView` with new layout:

```swift
struct AegisAdvancedCameraView: View {
    @StateObject private var cameraManager = CameraManager()
    let currentStep: PhotoCaptureStep
    let allSteps: [PhotoCaptureStep]
    let currentStepIndex: Int
    let capturedPhotos: [Int: UIImage]
    let onCapture: (UIImage) -> Void
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        ZStack {
            // Camera preview (full screen)
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                HeaderBar(onCancel: onCancel, onSave: onSave)

                // Main content area
                ZStack {
                    // Reference card (top-right)
                    VStack {
                        HStack {
                            Spacer()
                            ReferenceCardView(step: currentStep)
                                .padding(.trailing, 16)
                                .padding(.top, 8)
                        }
                        Spacer()
                    }

                    // Silhouette overlay (center)
                    SilhouetteOverlayView(step: currentStep)
                }

                // Instruction banner
                InstructionBannerView(text: currentStep.instruction)

                // Photo progress bar
                PhotoProgressBar(
                    steps: allSteps,
                    currentStepIndex: currentStepIndex,
                    capturedPhotos: capturedPhotos
                )
                .padding(.vertical, 12)
                .background(Color.black)

                // Camera controls
                CameraControlsBar(
                    onAlbum: { /* open album */ },
                    onCapture: { capturePhoto() },
                    onFlash: { toggleFlash() },
                    flashEnabled: cameraManager.flashEnabled
                )
                .padding(.bottom, 20)
                .background(Color.black)
            }
        }
    }
}
```

---

## Files to Create/Modify

### New Files
1. `Views/PhotoCapture/ReferenceCardView.swift`
2. `Views/PhotoCapture/SilhouetteOverlayView.swift`
3. `Views/PhotoCapture/InstructionBannerView.swift`
4. `Views/PhotoCapture/PhotoProgressBar.swift`

### Modified Files
1. `Models/PhotoCaptureStep.swift` - Add silhouette/reference image properties
2. `Views/PhotoCapture/AegisAdvancedCameraView.swift` - New layout
3. `Views/PhotoCapture/GuidanceOverlayView.swift` - Replace with new components
4. `Assets.xcassets/` - Add silhouette and reference images

### Assets to Add
```
Assets.xcassets/
├── Silhouettes/
│   ├── silhouette_outer_side.imageset/
│   ├── silhouette_inner_side.imageset/
│   ├── silhouette_sole.imageset/
│   ├── silhouette_heel.imageset/
│   ├── silhouette_tongue.imageset/
│   └── silhouette_sizetag.imageset/
└── References/
    ├── ref_outer_side.imageset/
    ├── ref_inner_side.imageset/
    ├── ref_sole.imageset/
    ├── ref_heel.imageset/
    ├── ref_tongue.imageset/
    └── ref_sizetag.imageset/
```

---

## Design Specifications

### Colors
- Header background: Black
- Instruction banner: Red/Pink (#E53935 or similar)
- Silhouette: White with 40% opacity
- Progress item border (current): White
- Progress item background: Gray 30% opacity
- Checkmark: Green (#4CAF50)

### Dimensions
- Reference card image: 80x80pt
- Silhouette max size: 280x350pt (varies by angle)
- Progress thumbnail: 50x50pt
- Instruction banner height: ~44pt

### Typography
- Step title: Caption, white
- Instruction text: Subheadline, white, centered
- Progress labels: 9pt system font

---

## Implementation Order

1. **Phase 1: Assets** (Current)
   - Create/source silhouette images
   - Create/source reference images
   - Add to Assets.xcassets

2. **Phase 2: Model Update**
   - Update PhotoCaptureStep with new properties
   - Define all 6 steps with proper assets

3. **Phase 3: UI Components**
   - Create ReferenceCardView
   - Create SilhouetteOverlayView
   - Create InstructionBannerView
   - Create PhotoProgressBar

4. **Phase 4: Integration**
   - Update AegisAdvancedCameraView layout
   - Wire up all components
   - Test camera capture flow

5. **Phase 5: Polish**
   - Animations
   - Transitions between steps
   - Error handling

---

## Questions for User

1. **Silhouette style:** Should silhouettes be simple white outlines or more detailed shoe shapes?
2. **Reference images:** Do you have reference photos to use, or should we use placeholder icons?
3. **6 photo angles:** Current app has 6 steps - confirm these are correct:
   - Outer Side
   - Inner Side
   - Sole/Bottom
   - Back/Heel
   - Tongue/Label
   - Size Tag

Ready to begin implementation?
