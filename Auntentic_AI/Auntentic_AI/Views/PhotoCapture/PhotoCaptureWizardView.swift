//
//  PhotoCaptureWizardView.swift
//  Auntentic_AI
//
//  Created on December 26, 2025.
//  Updated: January 3, 2026 - Aegis Gold Design System
//

import SwiftUI

/// Main coordinator view for the simplified 6-photo authentication process
struct PhotoCaptureWizardView: View {
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.dismiss) private var dismiss

    // State for captured images mapped by step
    @State private var capturedImages: [PhotoCaptureStep: UIImage] = [:]
    @State private var activeStep: PhotoCaptureStep? = nil
    @State private var showExitConfirmation = false
    @State private var showReviewScreen = false

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            // Aegis background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: { showExitConfirmation = true }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.aegisGoldMid)
                    }
                    
                    Spacer()
                    
                    Text("New Authentication")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)
                    
                    Spacer()
                    
                    // Start Button (only if all 6 photos captured)
                    Button(action: { showReviewScreen = true }) {
                        Text("Start")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(isReadyForAnalysis ? Color.aegisNavy : Color.aegisMuted)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(isReadyForAnalysis ? AnyView(LinearGradient.aegisGoldGradient) : AnyView(Color.aegisNavyElevated))
                            .clipShape(Capsule())
                    }
                    .disabled(!isReadyForAnalysis)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        headerText
                        
                        // 6-Photo Grid (3 rows of 2)
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(PhotoCaptureStep.allCases) { step in
                                PhotoGridCell(step: step, image: capturedImages[step]) {
                                    activeStep = step
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Instructions Hint
                        VStack(alignment: .center, spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.aegisGoldMid)
                            
                            Text("Fast AI Analysis: Requires all 6 photos")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.aegisGray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .fullScreenCover(item: $activeStep) { step in
            AegisAdvancedCameraView(
                capturedImages: $capturedImages,
                currentStep: step
            )
        }
        .navigationDestination(isPresented: $showReviewScreen) {
            PhotoReviewView(capturedImages: $capturedImages)
        }
        .confirmationDialog("Exit Authentication?", isPresented: $showExitConfirmation) {
            Button("Exit", role: .destructive) { dismiss() }
            Button("Cancel", role: .cancel) {}
        }
        .navigationBarHidden(true)
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Complete Photos")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.aegisWhite)
            
            Text("Follow the guides to capture 6 required angles")
                .font(.system(size: 16))
                .foregroundStyle(Color.aegisGray)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private var isReadyForAnalysis: Bool {
        capturedImages.count == 6
    }

    private func binding(for step: PhotoCaptureStep) -> Binding<UIImage?> {
        Binding(
            get: { capturedImages[step] },
            set: { if let img = $0 { capturedImages[step] = img } else { capturedImages.removeValue(forKey: step) } }
        )
    }
}

struct PhotoGridCell: View {
    let step: PhotoCaptureStep
    let image: UIImage?
    let action: () -> Void

    @State private var isAnimating = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.aegisNavyElevated)
                        .aspectRatio(1.1, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(image != nil ? Color.aegisSuccess : Color.aegisGoldMid.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(color: (image != nil ? Color.aegisSuccess : Color.aegisGoldMid).opacity(0.1), radius: 10, y: 5)

                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        // Animated reference image with white background - fills entire card
                        ZStack {
                            // White background for transparent PNG
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)

                            Image(step.referenceImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .opacity(isAnimating ? 0.95 : 0.7)
                        .scaleEffect(isAnimating ? 1.03 : 0.97)
                    }

                    if image != nil {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color.aegisSuccess)
                                    .background(Circle().fill(Color.aegisInk))
                                    .offset(x: 6, y: -6)
                            }
                            Spacer()
                        }
                    }
                }

                Text(step.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(image != nil ? Color.aegisWhite : Color.aegisGray)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}


#Preview {
    NavigationStack {
        PhotoCaptureWizardView()
    }
}
