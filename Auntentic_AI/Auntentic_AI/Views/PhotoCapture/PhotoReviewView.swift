//
//  PhotoReviewView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/27/25.
//  Updated: January 3, 2026 - Aegis Gold Design System
//

import SwiftUI
import OSLog

/// Review screen showing all captured photos with Aegis Gold design
struct PhotoReviewView: View {
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.imageUploadService) private var uploadService
    @Environment(\.sneakerAuthService) private var authService
    @Environment(\.authHistoryService) private var authHistoryService
    @Environment(\.networkMonitor) private var networkMonitor
    @Environment(\.creditManager) private var creditManager

    // Images passed from capture wizard
    @Binding var capturedImages: [PhotoCaptureStep: UIImage]

    // State
    @State private var showingRetakeSheet = false
    @State private var showingGalleryPicker = false
    @State private var selectedStep: PhotoCaptureStep? = nil
    @State private var showExitConfirmation = false
    @State private var isUploading = false
    @State private var isAuthenticating = false
    @State private var showUploadError = false
    @State private var currentError: AppError?
    @State private var authenticationResult: AuthenticationResult?
    @State private var showResults = false
    @State private var uploadedImageURLs: [URL] = []
    @State private var isAppeared = false
    @State private var showPurchaseSheet = false
    @State private var authenticationTask: Task<Void, Never>?
    @State private var showInvalidSubmissionAlert = false
    @State private var showPerImageAlert = false
    @State private var invalidPhotoIndices: [Int] = []

    private let logger = Logger(subsystem: "com.checkkicks.app", category: "PhotoReviewView")

    var body: some View {
        ZStack {
            // Aegis background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Offline Banner
                OfflineBanner()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                            .padding(.top, 20)
                            .opacity(isAppeared ? 1 : 0)
                            .offset(y: isAppeared ? 0 : -20)

                        // Photo Grid
                        photoGrid
                            .padding(.horizontal, 20)
                            .opacity(isAppeared ? 1 : 0)
                            .offset(y: isAppeared ? 0 : 20)

                        // Progress View (if active)
                        if isUploading || isAuthenticating {
                            progressSection
                                .padding(.horizontal, 20)
                        }

                        // AI Disclaimer
                        AegisDisclaimer()
                            .padding(.top, 8)
                            .opacity(isAppeared ? 1 : 0)

                        // Action Buttons
                        actionButtons
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                            .opacity(isAppeared ? 1 : 0)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(Color.aegisGoldMid)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isAppeared = true
            }
            logger.info("👁️ PhotoReviewView appeared")
        }
        .onDisappear {
            // Cancel any running authentication task when view is dismissed
            if let task = authenticationTask {
                task.cancel()
                logger.info("🛑 Authentication task cancelled on view dismiss")
            }
            authenticationTask = nil
        }
        .sheet(item: $selectedStep) { step in
            AegisAdvancedCameraView(
                capturedImages: $capturedImages,
                currentStep: step
            )
        }
        .confirmationDialog(
            "Retake All Photos?",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Retake All", role: .destructive) { dismiss() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will discard all current photos and start over.")
        }
        .alert("Error", isPresented: $showUploadError) {
            if let error = currentError, error.isRetryable {
                Button("Try Again") {
                    uploadService.reset()
                    authService.reset()
                    handleContinue()
                }
            }
            Button("OK", role: .cancel) {
                uploadService.reset()
                authService.reset()
                currentError = nil
            }
        } message: {
            if let error = currentError {
                Text(error.errorDescription ?? "An error occurred")
            } else {
                Text("An unexpected error occurred.")
            }
        }
        .sheet(isPresented: $showResults) {
            if let result = authenticationResult {
                NavigationStack {
                    ResultsView(result: result)
                }
            }
        }
        .sheet(isPresented: $showPurchaseSheet) {
            PurchaseView()
        }
        .alert("Photos Not Recognized", isPresented: $showInvalidSubmissionAlert) {
            Button("Retake Photos") {
                dismiss()  // Go back to camera
            }
            Button("Cancel", role: .cancel) {
                // Stay on review screen
            }
        } message: {
            if let result = authenticationResult, let reason = result.invalidReason {
                Text(reason)
            } else {
                Text("We couldn't identify footwear in your photos. Please take clear photos of the shoes you want to authenticate.")
            }
        }
        .alert("Some Photos Need Attention", isPresented: $showPerImageAlert) {
            Button("Retake Invalid Photos") {
                // Navigate back to camera to retake specific photos
                dismiss()
            }
            Button("Continue Anyway") {
                // Proceed with authentication despite invalid photos
                showResults = true
                HapticManager.success()
            }
            Button("Cancel", role: .cancel) {
                // Stay on review screen - clear invalid indices so badges disappear
                invalidPhotoIndices = []
            }
        } message: {
            Text(invalidPhotosMessage)
        }
    }

    // MARK: - Invalid Photos Message

    private var invalidPhotosMessage: String {
        guard let validations = authenticationResult?.perImageValidations else {
            return "Some photos could not be recognized as footwear."
        }
        let invalidPhotos = validations.filter { !$0.isValid }
        if invalidPhotos.isEmpty {
            return "Some photos could not be recognized as footwear."
        }
        return invalidPhotos
            .map { "Photo \($0.photoIndex) (\($0.photoType)): \($0.invalidReason ?? "Issue detected")" }
            .joined(separator: "\n")
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Review Your Photos")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.aegisWhite)

            Text("Tap any photo to retake or replace")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.aegisGray)
        }
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(Array(capturedImages.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { step in
                photoCard(for: step)
            }
        }
    }

    private func photoCard(for step: PhotoCaptureStep) -> some View {
        let image = capturedImages[step]
        let status: AegisPhotoCard.PhotoStatus = image != nil ? .captured : .empty
        // Convert step to 1-6 index for photoIndex matching
        let stepIndex = (PhotoCaptureStep.allCases.firstIndex(of: step) ?? 0) + 1
        let isInvalid = invalidPhotoIndices.contains(stepIndex)

        return Button(action: {
            HapticManager.lightImpact()
            selectedStep = step
            showingRetakeSheet = true
        }) {
            ZStack(alignment: .topTrailing) {
                AegisPhotoCard(
                    image: image,
                    title: step.title,
                    status: status
                )

                // Red badge for invalid photos
                if isInvalid {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)

                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.aegisError)
                    }
                    .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: 16) {
            if isUploading {
                // Upload progress
                VStack(spacing: 16) {
                    AegisProgressBar(progress: uploadService.uploadProgress)

                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.aegisGoldMid)

                        Text(uploadService.uploadStatus.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }

                    Text("\(Int(uploadService.uploadProgress * 100))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.aegisGoldMid)
                }
                .padding(24)
                .background(Color.aegisNavyLight)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
                )

            } else if isAuthenticating {
                // AI Analysis
                VStack(spacing: 20) {
                    AegisSpinner()
                        .scaleEffect(1.5)

                    Text("Analyzing...")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)

                    Text(authService.authenticationStatus.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(Color.aegisNavyLight)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 14) {
            // Primary CTA
            if isUploading || isAuthenticating {
                // Processing state
                HStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.aegisInk))
                    Text(isUploading ? "Uploading..." : "Analyzing...")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.aegisNavyElevated)
                .foregroundStyle(Color.aegisGray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            } else if !networkMonitor.isConnected {
                // No connection state
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 16, weight: .semibold))
                    Text("No Connection")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.aegisNavyElevated)
                .foregroundStyle(Color.aegisGray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            } else {
                // Ready state
                AegisPrimaryButton(title: "Authenticate Sneakers", icon: "sparkles") {
                    handleContinue()
                }
            }

            // Secondary action
            AegisGhostButton(title: "Retake All Photos", icon: "arrow.counterclockwise") {
                showExitConfirmation = true
            }
        }
    }

    // MARK: - Helpers

    private func binding(for step: PhotoCaptureStep) -> Binding<UIImage?> {
        Binding(
            get: { capturedImages[step] },
            set: { if let img = $0 { capturedImages[step] = img } else { capturedImages.removeValue(forKey: step) } }
        )
    }

    // MARK: - Actions

    private func handleContinue() {
        logger.info("➡️ Authenticate button tapped")

        // CRITICAL: Check credits BEFORE starting expensive upload operation
        guard creditManager.hasCredits || creditManager.hasAccountException else {
            logger.info("⚠️ No credits - showing purchase sheet")
            showPurchaseSheet = true
            HapticManager.warning()
            return
        }

        let images = capturedImages.values.map { $0 }

        isUploading = true

        // Store task reference for cancellation
        authenticationTask = Task {
            do {
                // Step 1: Upload images (only if credits available)
                logger.info("🚀 Starting upload...")
                let uploadedURLs = try await uploadService.uploadImages(images)

                // Check for cancellation after upload
                guard !Task.isCancelled else {
                    logger.info("🛑 Task cancelled - stopping after upload")
                    return
                }

                await MainActor.run {
                    isUploading = false
                    isAuthenticating = true
                    uploadedImageURLs = uploadedURLs
                    logger.info("✅ Upload successful!")
                }

                // Step 2: Authenticate
                logger.info("🤖 Starting authentication...")
                let result = try await authService.authenticate(imageURLs: uploadedURLs)

                // Check for cancellation after authentication
                guard !Task.isCancelled else {
                    logger.info("🛑 Task cancelled - stopping after authentication")
                    return
                }

                await MainActor.run {
                    isAuthenticating = false
                    authenticationResult = result

                    // Check for per-image issues FIRST (some photos invalid, but not all)
                    if !result.invalidPhotoIndices.isEmpty && result.isValidSubmission {
                        // Some photos are invalid but overall submission has some valid photos
                        invalidPhotoIndices = result.invalidPhotoIndices
                        showPerImageAlert = true
                        HapticManager.warning()
                        logger.info("⚠️ Per-image issues detected: \(result.invalidPhotoIndices)")
                        return
                    }

                    // Check if entire submission was invalid (no valid footwear at all)
                    if !result.isValidSubmission {
                        // Invalid submission - show alert, DON'T deduct credit or save to history
                        showInvalidSubmissionAlert = true
                        HapticManager.warning()
                        logger.info("⚠️ Invalid submission: \(result.invalidReason ?? "Unknown reason")")
                        return
                    }

                    // Valid submission with all photos valid - continue with normal flow
                    showResults = true
                    HapticManager.success()
                    logger.info("✅ Authentication complete!")
                }

                // Only save and deduct credit for valid submissions
                guard result.isValidSubmission else { return }

                // Step 3: Save to database (only for valid submissions)
                logger.info("💾 Saving to database...")
                do {
                    let _ = try await authHistoryService.saveAuthentication(
                        result: result,
                        imageUrls: uploadedURLs,
                        sneakerModel: nil
                    )
                } catch {
                    logger.error("⚠️ Save failed: \(error.localizedDescription)")
                }

                // Step 4: Deduct credit (only for valid submissions)
                logger.info("💰 Deducting credit...")
                do {
                    try await creditManager.useCredit()
                    logger.info("✅ Credit deducted")
                } catch {
                    logger.error("⚠️ Credit deduction failed: \(error.localizedDescription)")
                    // Don't fail the authentication if credit deduction fails
                    // The check was already performed, user should see results
                }

            } catch {
                // Check if error was due to cancellation
                if Task.isCancelled {
                    logger.info("🛑 Task was cancelled")
                    return
                }

                await MainActor.run {
                    isUploading = false
                    isAuthenticating = false
                    currentError = AppError.from(error)
                    showUploadError = true
                    HapticManager.error()
                    logger.error("❌ Process failed: \(error.localizedDescription)")
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        PhotoReviewView(capturedImages: .constant([
            .outerSide: UIImage(systemName: "photo")!
        ]))
        .environment(\.navigationCoordinator, NavigationCoordinator())
    }
}
