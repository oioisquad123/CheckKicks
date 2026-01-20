//
//  LegitStyleComponents.swift
//  Auntentic_AI
//
//  Premium UI Components matching the Legit app camera interface style
//  Redesigned: January 6, 2026
//

import SwiftUI

// MARK: - Design Constants

struct LegitDesign {
    // Colors matching Legit app
    static let coralRed = Color(red: 0.85, green: 0.27, blue: 0.32)      // #D94452 - Instruction banner
    static let burgundyRed = Color(red: 0.55, green: 0.10, blue: 0.12)   // #8B1A1A - Save button
    static let darkOverlay = Color.black.opacity(0.5)
    static let thumbnailBg = Color(white: 0.22, opacity: 0.4)
    static let mutedGray = Color(white: 0.6)
    static let successGreen = Color(red: 0.13, green: 0.77, blue: 0.37)  // #22C55E

    // Sizing
    static let referenceCardSize: CGFloat = 88
    static let referenceImageSize: CGFloat = 82
    static let thumbnailSize: CGFloat = 58
    static let captureButtonOuter: CGFloat = 82
    static let captureButtonInner: CGFloat = 68
    static let headerHeight: CGFloat = 54
}

// MARK: - Thumbnail Silhouette (Bottom Progress Bar Icons)

struct ThumbnailSilhouette: View {
    let step: PhotoCaptureStep
    let isCurrent: Bool

    var body: some View {
        Group {
            switch step {
            case .outerSide:
                // Outer side faces LEFT (matching reference image)
                ShoeProfileShape()
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .scaleEffect(x: -1, y: 1)
            case .innerSide:
                // Inner side faces RIGHT
                ShoeProfileShape()
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            case .soleView:
                SoleShape()
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            case .heelDetail:
                HeelShape()
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            case .tongueLabel:
                TongueThumbnailShape()
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            case .sizeTag:
                SizeTagThumbnailShape()
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: 38, height: 38)
    }

    private var strokeColor: Color {
        isCurrent ? .white : LegitDesign.mutedGray
    }
}

// MARK: - Tongue Thumbnail Shape

struct TongueThumbnailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Tongue shape - rounded top rectangle
        path.move(to: CGPoint(x: w * 0.2, y: h * 0.95))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.35))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.1),
            control: CGPoint(x: w * 0.2, y: h * 0.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.8, y: h * 0.35),
            control: CGPoint(x: w * 0.8, y: h * 0.1)
        )
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.95))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.95))
        path.closeSubpath()

        // Inner lines for label
        path.move(to: CGPoint(x: w * 0.35, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.5))
        path.move(to: CGPoint(x: w * 0.35, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.65))

        return path
    }
}

// MARK: - Size Tag Thumbnail Shape

struct SizeTagThumbnailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Tag shape with rounded corners
        let cornerRadius: CGFloat = w * 0.1
        path.addRoundedRect(
            in: CGRect(x: w * 0.15, y: h * 0.2, width: w * 0.7, height: h * 0.6),
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )

        // Inner lines for text
        path.move(to: CGPoint(x: w * 0.3, y: h * 0.4))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.4))
        path.move(to: CGPoint(x: w * 0.3, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.55))
        path.move(to: CGPoint(x: w * 0.3, y: h * 0.7))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.7))

        return path
    }
}

// MARK: - Reference Card View (Top-Right) - SIMPLIFIED (Direct Image Display)

struct ReferenceCardView: View {
    let step: PhotoCaptureStep
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Outer white border with shadow
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: LegitDesign.referenceCardSize, height: LegitDesign.referenceCardSize)
                .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)

            // Reference image - direct display (white background shows through)
            Image(step.referenceImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: LegitDesign.referenceImageSize, height: LegitDesign.referenceImageSize)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: step)
        .onChange(of: step) { _, _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - Reference Silhouette View (Ghosted reference image for uncaptured steps)

struct ReferenceSilhouetteView: View {
    let step: PhotoCaptureStep
    let isCurrent: Bool

    var body: some View {
        // Reference image with white background for transparent PNGs
        ZStack {
            // White background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: 48, height: 48)

            // Reference image
            Image(step.referenceImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .opacity(isCurrent ? 0.9 : 0.7)
    }
}

// MARK: - Instruction Banner View (Coral Bar) - REFINED

struct InstructionBannerView: View {
    let text: String
    var backgroundColor: Color = LegitDesign.coralRed

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .lineLimit(2)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
    }
}

// MARK: - Photo Progress Bar (Bottom Thumbnails) - REFINED

struct PhotoProgressBar: View {
    let steps: [PhotoCaptureStep]
    let currentStep: PhotoCaptureStep
    let capturedPhotos: [PhotoCaptureStep: UIImage]
    let onStepTapped: (PhotoCaptureStep) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(steps) { step in
                        PhotoProgressItem(
                            step: step,
                            isCurrent: step == currentStep,
                            capturedImage: capturedPhotos[step],
                            onTap: { onStepTapped(step) }
                        )
                        .id(step)
                    }
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: currentStep) { _, newValue in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
}

struct PhotoProgressItem: View {
    let step: PhotoCaptureStep
    let isCurrent: Bool
    let capturedImage: UIImage?
    let onTap: () -> Void

    private let itemSize: CGFloat = LegitDesign.thumbnailSize

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(LegitDesign.thumbnailBg)
                    .frame(width: itemSize, height: itemSize)

                // Captured image or reference silhouette
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: itemSize, height: itemSize)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Use reference image silhouette (ghosted shoe image)
                    ReferenceSilhouetteView(step: step, isCurrent: isCurrent)
                }

                // Current step border with glow
                if isCurrent {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2.5)
                        .frame(width: itemSize, height: itemSize)
                        .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 0)
                }

                // Checkmark for completed
                if capturedImage != nil {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(LegitDesign.successGreen)
                            }
                            .offset(x: 5, y: -5)
                        }
                        Spacer()
                    }
                    .frame(width: itemSize, height: itemSize)
                }
            }

            // Label
            Text(step.shortTitle)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isCurrent ? .white : LegitDesign.mutedGray)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: itemSize + 12)
        }
        .onTapGesture {
            onTap()
            HapticManager.lightImpact()
        }
        .scaleEffect(isCurrent ? 1.0 : 0.95)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrent)
    }
}

// MARK: - Camera Controls Bar - REFINED

struct CameraControlsBar: View {
    let onAlbumTapped: () -> Void
    let onCaptureTapped: () -> Void
    let onFlashTapped: () -> Void
    let isFlashOn: Bool

    @State private var isCapturing = false

    var body: some View {
        HStack {
            // Album button
            Button(action: {
                HapticManager.lightImpact()
                onAlbumTapped()
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 28, weight: .medium))
                    Text("Select from\nalbum")
                        .font(.system(size: 10, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)

            // Capture button - Premium style
            Button(action: {
                withAnimation(.easeOut(duration: 0.1)) {
                    isCapturing = true
                }
                HapticManager.mediumImpact()
                onCaptureTapped()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isCapturing = false
                    }
                }
            }) {
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: LegitDesign.captureButtonOuter, height: LegitDesign.captureButtonOuter)

                    // Inner filled circle
                    Circle()
                        .fill(Color.white)
                        .frame(width: LegitDesign.captureButtonInner, height: LegitDesign.captureButtonInner)
                }
                .scaleEffect(isCapturing ? 0.92 : 1.0)
            }
            .frame(maxWidth: .infinity)

            // Flash button
            Button(action: {
                HapticManager.lightImpact()
                onFlashTapped()
            }) {
                VStack(spacing: 6) {
                    Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(isFlashOn ? .yellow : .white)
                    Text("Flashlight\n\(isFlashOn ? "on" : "off")")
                        .font(.system(size: 10, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Header Bar - REFINED (Legit Style)

struct CameraHeaderBar: View {
    let onCancel: () -> Void
    let onSave: () -> Void
    let canSave: Bool

    var body: some View {
        HStack {
            // Cancel button
            Button(action: {
                HapticManager.lightImpact()
                onCancel()
            }) {
                Text("CANCEL")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Title
            Text("Required")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            // Save button - Burgundy red style
            Button(action: {
                HapticManager.mediumImpact()
                onSave()
            }) {
                Text("SAVE")
                    .font(.system(size: 15, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(canSave ? LegitDesign.burgundyRed : Color.gray.opacity(0.4))
                    )
                    .foregroundStyle(canSave ? .white : .white.opacity(0.5))
            }
            .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
}

// MARK: - PhotoCaptureStep Extension for Short Title

extension PhotoCaptureStep {
    var shortTitle: String {
        switch self {
        case .outerSide: return "Exterior\nOuter"
        case .innerSide: return "Exterior\nInner"
        case .sizeTag: return "Size\nTag"
        case .soleView: return "Sole"
        case .tongueLabel: return "Tongue\nLabel"
        case .heelDetail: return "Heel"
        }
    }
}

// MARK: - Previews

#Preview("Reference Card") {
    ZStack {
        Color.black.ignoresSafeArea()
        ReferenceCardView(step: .outerSide)
    }
}

#Preview("Progress Bar") {
    ZStack {
        Color.black.ignoresSafeArea()
        PhotoProgressBar(
            steps: PhotoCaptureStep.allCases,
            currentStep: .innerSide,
            capturedPhotos: [.outerSide: UIImage()],
            onStepTapped: { _ in }
        )
    }
}

#Preview("Instruction Banner") {
    InstructionBannerView(text: "Pinch to zoom and tap to focus.\nPhotograph your product in full.")
}

#Preview("Camera Controls") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            CameraControlsBar(
                onAlbumTapped: {},
                onCaptureTapped: {},
                onFlashTapped: {},
                isFlashOn: false
            )
            .padding(.bottom, 40)
        }
    }
}

#Preview("Header Bar") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            CameraHeaderBar(
                onCancel: {},
                onSave: {},
                canSave: true
            )
            .background(Color.black.opacity(0.5))
            Spacer()
        }
    }
}
