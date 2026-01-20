//
//  AegisAdvancedCameraView.swift
//  Auntentic_AI
//
//  Legit-style camera interface with premium design
//  Redesigned: January 6, 2026
//

import SwiftUI
import AVFoundation
import UIKit

struct AegisAdvancedCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraManager()

    @Binding var capturedImages: [PhotoCaptureStep: UIImage]
    @State var currentStep: PhotoCaptureStep
    var allSteps: [PhotoCaptureStep] = PhotoCaptureStep.allCases

    @State private var showingGallery = false
    @State private var flashSuccess = false
    @State private var silhouettePulse = false

    // Calculate if we can save (at least one photo captured)
    private var canSave: Bool {
        !capturedImages.isEmpty
    }

    var body: some View {
        GeometryReader { geometry in
            let squareSize = geometry.size.width - 32  // Square camera with padding

            ZStack {
                Color.black.ignoresSafeArea()

                // Main Layout
                VStack(spacing: 0) {
                    // Safe area spacer for status bar
                    Color.clear.frame(height: geometry.safeAreaInsets.top)

                    // Header Bar
                    CameraHeaderBar(
                        onCancel: { dismiss() },
                        onSave: { dismiss() },
                        canSave: canSave
                    )
                    .background(
                        LegitDesign.darkOverlay
                            .blur(radius: 0.5)
                    )

                    Spacer(minLength: 8)

                    // Square Camera Container - What you see = what you capture
                    ZStack {
                        // Camera Preview - constrained to square, fills with .resizeAspectFill
                        CameraPreview(session: camera.session, previewSize: $camera.previewSize)
                            .frame(width: squareSize, height: squareSize)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Corner brackets overlay
                        SquareBracketsOverlay()
                            .frame(width: squareSize, height: squareSize)

                        // Reference Card (Top-Right inside square)
                        VStack {
                            HStack {
                                Spacer()
                                ReferenceCardView(step: currentStep)
                                    .padding(.trailing, 8)
                                    .padding(.top, 8)
                            }
                            Spacer()
                        }
                        .frame(width: squareSize, height: squareSize)

                        // Centered Silhouette Overlay
                        SilhouetteOverlayView(step: currentStep, opacity: silhouettePulse ? 0.35 : 0.25)
                            .scaleEffect(silhouettePulse ? 1.02 : 1.0)
                            .frame(width: squareSize * 0.7, height: squareSize * 0.7)
                    }
                    .frame(width: squareSize, height: squareSize)

                    Spacer(minLength: 8)

                    // Instruction Banner (Coral Red)
                    InstructionBannerView(text: currentStep.hintText)

                    // Bottom Section (Black background)
                    VStack(spacing: 0) {
                        // Photo Progress Thumbnails
                        PhotoProgressBar(
                            steps: allSteps,
                            currentStep: currentStep,
                            capturedPhotos: capturedImages,
                            onStepTapped: { step in
                                withAnimation(.spring(response: 0.3)) {
                                    currentStep = step
                                }
                            }
                        )
                        .padding(.vertical, 16)

                        // Camera Controls
                        CameraControlsBar(
                            onAlbumTapped: { showingGallery = true },
                            onCaptureTapped: { camera.takePhoto() },
                            onFlashTapped: { camera.toggleFlash() },
                            isFlashOn: camera.isFlashOn
                        )
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                    }
                    .background(Color.black)
                }
                .ignoresSafeArea(edges: .top)

                // Flash Success Overlay
                if flashSuccess {
                    Color.white.opacity(0.85)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        }
        .task {
            camera.checkPermissions()
        }
        .onAppear {
            startSilhouetteAnimation()
        }
        .onChange(of: camera.capturedImage) { _, newValue in
            handleCapturedImage(newValue)
        }
        .sheet(isPresented: $showingGallery) {
            GalleryPicker(selectedImage: Binding(
                get: { nil },
                set: { image in
                    if let img = image {
                        capturedImages[currentStep] = img.normalizedOrientation().croppedToSquare()
                        moveToNextStep()
                    }
                }
            ))
        }
        .navigationBarHidden(true)
        .statusBarHidden(false)
    }

    // MARK: - Private Methods

    private func startSilhouetteAnimation() {
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            silhouettePulse = true
        }
    }

    private func handleCapturedImage(_ image: UIImage?) {
        guard let image = image else { return }

        withAnimation(.easeOut(duration: 0.15)) {
            flashSuccess = true
        }

        // Store the image (already processed by CameraManager: normalized + cropped to match preview)
        capturedImages[currentStep] = image
        HapticManager.photoCaptured()

        // Hide flash and move to next step
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.15)) {
                flashSuccess = false
            }
            moveToNextStep()
        }
    }

    private func moveToNextStep() {
        // Find next step that doesn't have a photo
        let remainingSteps = allSteps.filter { capturedImages[$0] == nil }
        if let nextStep = remainingSteps.first {
            withAnimation(.spring(response: 0.35)) {
                currentStep = nextStep
            }
        }
    }
}

// MARK: - Square Brackets Overlay

/// Corner brackets overlay for the square camera container
/// Simple and clean - no complex position calculations needed
struct SquareBracketsOverlay: View {
    var body: some View {
        Canvas { context, size in
            let bracketLength: CGFloat = 28
            let bracketWidth: CGFloat = 3
            let inset: CGFloat = 4

            // Draw corner brackets at exact corners of the canvas
            // Top-left
            var topLeft = Path()
            topLeft.move(to: CGPoint(x: inset, y: inset + bracketLength))
            topLeft.addLine(to: CGPoint(x: inset, y: inset))
            topLeft.addLine(to: CGPoint(x: inset + bracketLength, y: inset))
            context.stroke(topLeft, with: .color(.white), lineWidth: bracketWidth)

            // Top-right
            var topRight = Path()
            topRight.move(to: CGPoint(x: size.width - inset - bracketLength, y: inset))
            topRight.addLine(to: CGPoint(x: size.width - inset, y: inset))
            topRight.addLine(to: CGPoint(x: size.width - inset, y: inset + bracketLength))
            context.stroke(topRight, with: .color(.white), lineWidth: bracketWidth)

            // Bottom-left
            var bottomLeft = Path()
            bottomLeft.move(to: CGPoint(x: inset, y: size.height - inset - bracketLength))
            bottomLeft.addLine(to: CGPoint(x: inset, y: size.height - inset))
            bottomLeft.addLine(to: CGPoint(x: inset + bracketLength, y: size.height - inset))
            context.stroke(bottomLeft, with: .color(.white), lineWidth: bracketWidth)

            // Bottom-right
            var bottomRight = Path()
            bottomRight.move(to: CGPoint(x: size.width - inset - bracketLength, y: size.height - inset))
            bottomRight.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset))
            bottomRight.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset - bracketLength))
            context.stroke(bottomRight, with: .color(.white), lineWidth: bracketWidth)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview {
    AegisAdvancedCameraView(
        capturedImages: .constant([:]),
        currentStep: .outerSide
    )
}
