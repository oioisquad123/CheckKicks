//
//  OnboardingView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Updated: January 18, 2026 - Onboarding v2 with improved UX
//

import SwiftUI
import AVFoundation

/// 5-screen onboarding flow with Aegis Gold design
/// v2: Added social proof, emotional hook, camera permission priming
struct OnboardingView: View {
    @Environment(\.navigationCoordinator) private var coordinator
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var currentPage = 0
    @State private var isAnimating = false

    private let totalPages = 5  // Welcome, PainPoint, HowItWorks, Results+Value, CameraPermission

    var body: some View {
        ZStack {
            // Aegis gradient background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: completeOnboarding) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.aegisGray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    .opacity(currentPage < totalPages - 1 ? 1 : 0)
                }
                .padding(.top, 16)
                .padding(.trailing, 8)

                // Page content
                TabView(selection: $currentPage) {
                    AegisWelcomePage()
                        .tag(0)

                    AegisPainPointPage()
                        .tag(1)

                    AegisHowItWorksPage()
                        .tag(2)

                    AegisResultsValuePage()
                        .tag(3)

                    AegisCameraPermissionPage(onComplete: completeOnboarding)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)

                // Page indicator and navigation
                VStack(spacing: 32) {
                    // Custom page indicator with gold accent
                    HStack(spacing: 12) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.aegisGoldMid : Color.aegisGray.opacity(0.4))
                                .frame(width: index == currentPage ? 32 : 8, height: 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }

                    // Next button (except on last page which has its own buttons)
                    if currentPage < totalPages - 1 {
                        Button(action: nextPage) {
                            HStack(spacing: 8) {
                                Text("Next")
                                    .font(.system(size: 17, weight: .bold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(Color.aegisInk)
                            .padding(.horizontal, 48)
                            .padding(.vertical, 18)
                            .background(LinearGradient.aegisGoldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.aegisGoldMid.opacity(0.4), radius: 16, y: 8)
                        }
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                isAnimating = true
                            }
                        }
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .onAppear {
            HapticManager.lightImpact()
        }
        .onChange(of: currentPage) { _, _ in
            HapticManager.selectionChanged()
        }
    }

    // MARK: - Actions

    private func nextPage() {
        HapticManager.mediumImpact()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage += 1
        }
    }

    private func completeOnboarding() {
        HapticManager.success()
        hasSeenOnboarding = true
        coordinator.navigateToAuth()
    }
}

// MARK: - Screen 1: Welcome + Social Proof

private struct AegisWelcomePage: View {
    @State private var isAnimated = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Animated shield icon with gold rings
            ZStack {
                // Outer glow rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient.aegisGoldGradient,
                            lineWidth: 2
                        )
                        .frame(width: CGFloat(180 + index * 40), height: CGFloat(180 + index * 40))
                        .scaleEffect(isAnimated ? 1.0 : 0.8)
                        .opacity(isAnimated ? 0.4 - Double(index) * 0.12 : 0)
                }

                // Main icon
                Image("LuxuriousShield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                    .shadow(color: Color.aegisGoldMid.opacity(0.4), radius: 30, y: 10)
                    .scaleEffect(isAnimated ? 1.0 : 0.5)
                    .rotationEffect(.degrees(isAnimated ? 360 : 0))
                    .opacity(isAnimated ? 1.0 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                    isAnimated = true
                }
            }

            // Text content with social proof
            VStack(spacing: 16) {
                Text("CheckKicks")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                // Social proof badge
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.aegisGoldMid)
                    Text("Trusted by sneakerheads worldwide")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGoldMid)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.aegisGoldMid.opacity(0.15))
                .clipShape(Capsule())

                Text("Know it's real before you pay.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 30)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 2: Pain Point + Solution

private struct AegisPainPointPage: View {
    @State private var isAnimated = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Warning icon with shield
            ZStack {
                Circle()
                    .fill(Color.aegisWarning.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimated ? 1.0 : 0.8)
                    .opacity(isAnimated ? 1.0 : 0)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(Color.aegisWarning)
                    .scaleEffect(isAnimated ? 1.0 : 0.5)
                    .opacity(isAnimated ? 1.0 : 0)
            }

            // Header
            VStack(spacing: 16) {
                Text("Stop Buying Fakes")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)
                    .multilineTextAlignment(.center)

                Text("Over $3 billion in counterfeit sneakers sold each year. Don't be a victim.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 20)

            // Solution highlight
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image("LuxuriousShield")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI-Powered Protection")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.aegisWhite)
                        Text("47 authenticity markers analyzed")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }

                    Spacer()
                }
                .padding(20)
                .background(Color.aegisNavyLight)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.aegisGoldMid.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 30)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimated)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimated = true
            }
        }
    }
}

// MARK: - Screen 3: How It Works

private struct AegisHowItWorksPage: View {
    @State private var isAnimated = false

    private let steps = [
        AegisOnboardingStep(icon: "camera.fill", title: "Snap 6 Photos", description: "Quick angles of your sneakers"),
        AegisOnboardingStep(icon: "cpu.fill", title: "AI Analyzes", description: "47 markers checked in seconds"),
        AegisOnboardingStep(icon: "checkmark.shield.fill", title: "Get Your Verdict", description: "Confidence score + report")
    ]

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Text("Simple & Fast")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                Text("Authentication in 3 easy steps")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
            }
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 20)

            // Steps
            VStack(spacing: 20) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    AegisStepRow(step: step, index: index + 1)
                        .opacity(isAnimated ? 1.0 : 0)
                        .offset(x: isAnimated ? 0 : -50)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.15), value: isAnimated)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimated = true
            }
        }
    }
}

private struct AegisOnboardingStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

private struct AegisStepRow: View {
    let step: AegisOnboardingStep
    let index: Int

    var body: some View {
        HStack(spacing: 20) {
            // Icon circle with gold gradient
            ZStack {
                Circle()
                    .fill(Color.aegisNavyLight)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(LinearGradient.aegisGoldGradient, lineWidth: 2)
                    )

                Image(systemName: step.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.aegisGoldMid)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                Text(step.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
            }

            Spacer()

            // Step number
            Text("\(index)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.aegisGoldMid.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.aegisNavyLight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Screen 4: Results Demo + Value (Combined)

private struct AegisResultsValuePage: View {
    @State private var isAnimated = false
    @State private var confidence: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Text("Get Your Answer")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                Text("AI-powered confidence scores")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
            }
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 20)

            // Result preview
            VStack(spacing: 20) {
                // Confidence circle
                ZStack {
                    Circle()
                        .stroke(Color.aegisNavyElevated, lineWidth: 10)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: confidence)
                        .stroke(
                            Color.aegisSuccess,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(Int(confidence * 100))%")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color.aegisWhite)

                        Text("Confidence")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }
                }

                // Verdict badge
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Likely Authentic")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(Color.aegisInk)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.aegisSuccess)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.aegisSuccess.opacity(0.4), radius: 10, y: 4)
            }
            .opacity(isAnimated ? 1.0 : 0)
            .scaleEffect(isAnimated ? 1.0 : 0.8)

            // Divider
            Rectangle()
                .fill(Color.aegisGoldMid.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 40)
                .opacity(isAnimated ? 1.0 : 0)

            // Free credits offer
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.aegisGoldMid)

                    Text("Start with 3 Free Checks")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.aegisGoldMid)
                }

                VStack(spacing: 4) {
                    Text("No credit card required")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                    Text("Credits never expire")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.aegisGoldMid.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimated)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimated = true
            }
            withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                confidence = 0.87
            }
        }
    }
}

// MARK: - Screen 5: Camera Permission Priming + Get Started

private struct AegisCameraPermissionPage: View {
    let onComplete: () -> Void

    @State private var isAnimated = false
    @State private var isPulsing = false
    @State private var showingDisclaimer = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Camera icon with pulsing rings
            ZStack {
                // Pulsing rings
                ForEach(0..<2) { index in
                    Circle()
                        .stroke(Color.aegisGoldMid.opacity(0.3), lineWidth: 2)
                        .frame(width: CGFloat(140 + index * 30), height: CGFloat(140 + index * 30))
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 0.6)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                            value: isPulsing
                        )
                }

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.aegisGoldLight, Color.aegisGoldDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.aegisGoldMid.opacity(0.4), radius: 20, y: 8)

                Image(systemName: "camera.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(Color.aegisInk)
            }
            .scaleEffect(isAnimated ? 1.0 : 0.5)
            .opacity(isAnimated ? 1.0 : 0)

            // Header
            VStack(spacing: 12) {
                Text("Ready to Check\nYour Kicks?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)
                    .multilineTextAlignment(.center)
            }
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 20)

            // Camera benefits
            VStack(alignment: .leading, spacing: 12) {
                cameraFeatureRow(icon: "camera.viewfinder", text: "Capture clear authentication photos")
                cameraFeatureRow(icon: "cpu", text: "Get accurate AI analysis")
                cameraFeatureRow(icon: "location.fill", text: "Scan sneakers anywhere, anytime")
            }
            .padding(.horizontal, 32)
            .opacity(isAnimated ? 1.0 : 0)
            .offset(y: isAnimated ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: isAnimated)

            Spacer()

            // Buttons
            VStack(spacing: 16) {
                // Primary button - Enable Camera
                Button(action: requestCameraPermission) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Enable Camera & Start")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(Color.aegisInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(LinearGradient.aegisGoldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.aegisGoldMid.opacity(0.4), radius: 12, y: 6)
                }

                // Secondary button - Maybe Later
                Button(action: onComplete) {
                    Text("Maybe Later")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.aegisGray)
                }
            }
            .padding(.horizontal, 32)
            .opacity(isAnimated ? 1.0 : 0)

            // Embedded disclaimer
            VStack(spacing: 8) {
                Text("By continuing, you agree that CheckKicks provides")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.aegisGray.opacity(0.8))

                HStack(spacing: 4) {
                    Text("AI-assisted analysis for informational purposes only.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.aegisGray.opacity(0.8))

                    Button(action: { showingDisclaimer = true }) {
                        Text("See full terms")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.aegisGoldMid)
                            .underline()
                    }
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .opacity(isAnimated ? 1.0 : 0)
        }
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                isAnimated = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPulsing = true
            }
        }
        .sheet(isPresented: $showingDisclaimer) {
            DisclaimerSheetView()
        }
    }

    private func cameraFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.aegisGoldMid)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.aegisWhite)
        }
    }

    private func requestCameraPermission() {
        HapticManager.mediumImpact()

        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                // Complete onboarding regardless of permission result
                // Permission will be requested again when needed if denied
                HapticManager.success()
                onComplete()
            }
        }
    }
}

// MARK: - Disclaimer Sheet View

private struct DisclaimerSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.aegisNavyGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Important Disclaimer")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.aegisWhite)

                            Text("Please read before using CheckKicks")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.aegisGray)
                        }

                        // Disclaimer content
                        VStack(alignment: .leading, spacing: 16) {
                            disclaimerRow(icon: "info.circle.fill", text: "CheckKicks provides AI-assisted analysis for informational purposes only")
                            disclaimerRow(icon: "xmark.shield.fill", text: "Results are NOT a guarantee of authenticity")
                            disclaimerRow(icon: "person.badge.shield.checkmark.fill", text: "Always consult professional authenticators for high-value purchases")
                            disclaimerRow(icon: "doc.text.fill", text: "We are not liable for decisions made based on our analysis")
                        }
                        .padding(20)
                        .background(Color.aegisNavyLight)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
                        )

                        Spacer()
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.aegisGoldMid)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func disclaimerRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.aegisGoldMid)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.aegisGray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environment(\.navigationCoordinator, NavigationCoordinator())
}
