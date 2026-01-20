//
//  ProcessingView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 02/01/26.
//  Premium processing screen with Aegis Gold theme
//

import SwiftUI

/// Premium processing view with animated scanner and cycling status messages
struct ProcessingView: View {
    // MARK: - Properties

    @Environment(\.navigationCoordinator) private var coordinator

    /// Progress value from 0 to 1
    let progress: Double

    /// Optional completion handler when processing finishes
    var onComplete: (() -> Void)?

    // MARK: - State

    @State private var currentMessageIndex = 0
    @State private var textOpacity: Double = 1
    @State private var scannerPhase: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringRotation: Double = 0

    // MARK: - Status Messages

    private let statusMessages = [
        "Analyzing stitching patterns…",
        "Checking logo proportions…",
        "Examining material quality…",
        "Verifying brand markings…",
        "Comparing with authentic samples…",
        "Generating authentication verdict…"
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            // Aegis Background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            // Shield watermark
            Image("LuxuriousShield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .opacity(0.02)
                .blur(radius: 2)

            VStack(spacing: 40) {
                Spacer()

                // Animated Scanner
                scannerView

                // Status Text
                statusTextView

                // Progress Indicator
                progressView

                Spacer()

                // Time Estimate Tip
                tipView
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Scanner View

    private var scannerView: some View {
        ZStack {
            // Outer pulsing glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.aegisGoldMid.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(pulseScale)

            // Rotating outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.aegisGoldLight.opacity(0.8),
                            Color.aegisGoldMid.opacity(0.4),
                            Color.aegisGoldDark.opacity(0.2),
                            Color.clear,
                            Color.aegisGoldLight.opacity(0.8)
                        ],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(ringRotation))

            // Middle static ring
            Circle()
                .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 2)
                .frame(width: 140, height: 140)

            // Inner gradient circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.aegisNavyLight, Color.aegisNavy],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(Color.aegisGoldMid.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(color: Color.aegisGoldMid.opacity(0.3), radius: 20)

            // Shield with sparkles
            ZStack {
                // Shield icon
                Image("LuxuriousShield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                // Scanning line effect
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.aegisGoldLight.opacity(0.8),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 8)
                    .offset(y: -30 + (scannerPhase * 60))

                // Sparkle overlay
                Image(systemName: "sparkle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.aegisGoldLight)
                    .offset(x: 25, y: -25)
                    .opacity(scannerPhase > 0.5 ? 1 : 0.3)
            }
            .clipShape(Circle())
        }
    }

    // MARK: - Status Text View

    private var statusTextView: some View {
        VStack(spacing: 12) {
            Text(statusMessages[currentMessageIndex])
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.aegisWhite)
                .opacity(textOpacity)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.3), value: currentMessageIndex)

            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<statusMessages.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentMessageIndex ?
                              Color.aegisGoldMid :
                              Color.aegisGoldMid.opacity(0.2))
                        .frame(width: 6, height: 6)
                        .animation(.spring(response: 0.3), value: currentMessageIndex)
                }
            }
        }
    }

    // MARK: - Progress View

    private var progressView: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.aegisNavyElevated)
                        .frame(height: 8)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(LinearGradient.aegisGoldGradient)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 8)

            // Percentage
            Text("\(Int(progress * 100))% complete")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.aegisGray)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Tip View

    private var tipView: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.aegisGoldMid.opacity(0.6))

            Text("This takes about 10-20 seconds")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.aegisMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.aegisNavyLight.opacity(0.5))
        )
    }

    // MARK: - Animations

    private func startAnimations() {
        // Ring rotation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }

        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }

        // Scanner line animation
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            scannerPhase = 1
        }

        // Message cycling
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { timer in
            withAnimation(.easeOut(duration: 0.2)) {
                textOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentMessageIndex = (currentMessageIndex + 1) % statusMessages.count
                withAnimation(.easeIn(duration: 0.2)) {
                    textOpacity = 1
                }
            }
        }
    }
}

// MARK: - Compact Processing Overlay

/// Overlay version of processing view for use within other screens
struct ProcessingOverlay: View {
    let message: String
    var showProgress: Bool = true
    var progress: Double = 0

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.aegisNavy.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Spinner
                AegisSpinner(size: 80, lineWidth: 5)

                // Message
                Text(message)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.aegisWhite)
                    .multilineTextAlignment(.center)

                // Optional progress bar
                if showProgress {
                    VStack(spacing: 6) {
                        AegisProgressBar(progress: progress, height: 6)
                            .padding(.horizontal, 60)

                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Processing View") {
    ProcessingView(progress: 0.65)
        .environment(\.navigationCoordinator, NavigationCoordinator())
}

#Preview("Aegis Spinner") {
    ZStack {
        Color.aegisNavy.ignoresSafeArea()
        AegisSpinner(size: 80, lineWidth: 5)
    }
}

#Preview("Processing Overlay") {
    ProcessingOverlay(
        message: "Uploading photos…",
        showProgress: true,
        progress: 0.45
    )
}
