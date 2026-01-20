//
//  SplashView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Task 5: Splash Screen - Updated with Aegis Gold theme
//

import SwiftUI
import OSLog

/// Initial splash screen displayed on app launch with Aegis Gold theme
struct SplashView: View {
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.authenticationService) private var authService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    private let logger = Logger(subsystem: "com.checkkicks.app", category: "SplashView")

    @State private var isAnimating = false
    @State private var shieldScale: CGFloat = 0.8
    @State private var glowOpacity: Double = 0.3
    @State private var rotationDegrees: Double = 0

    var body: some View {
        ZStack {
            // Aegis Navy Background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            // Subtle grid pattern overlay (tech feel)
            gridOverlay
                .opacity(0.03)

            VStack(spacing: 32) {
                Spacer()

                // Animated Gold Shield Icon
                shieldIcon
                    .scaleEffect(shieldScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            shieldScale = 1.0
                        }
                        withAnimation(.easeInOut(duration: 1.2).delay(0.2)) {
                            rotationDegrees = 360
                        }
                    }

                // App Name with gold gradient
                Text("CheckKicks")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient.aegisGoldGradient)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)

                // Tagline
                Text("AI-Powered Sneaker Authentication")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 15)

                Spacer()

                // Aegis Gold Spinner
                AegisSpinner(size: 36, lineWidth: 3)
                    .opacity(isAnimating ? 1 : 0)

                Spacer()
                    .frame(height: 60)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                isAnimating = true
            }
            // Glow pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
        }
        .task {
            logger.info("SplashView task started")

            // Check for existing session in parallel with minimum splash time
            async let sessionCheck: Void = authService.checkExistingSession()

            // Show splash for minimum 2.5 seconds for branding
            logger.info("Showing splash screen for minimum 2.5 seconds...")
            try? await Task.sleep(nanoseconds: 2_500_000_000)

            // Wait for session check to complete
            logger.info("Waiting for session check to complete...")
            await sessionCheck

            // Navigate based on onboarding and authentication state
            logger.info("Navigation decision: hasSeenOnboarding = \(hasSeenOnboarding), isAuthenticated = \(authService.isAuthenticated)")

            if !hasSeenOnboarding {
                logger.info("First-time user - navigating to Onboarding")
                coordinator.navigateToOnboarding()
            } else if authService.isAuthenticated {
                logger.info("User authenticated - navigating to Home")
                coordinator.navigateToHome()
            } else {
                logger.info("User not authenticated - navigating to Auth")
                coordinator.navigateToAuth()
            }

            logger.info("SplashView task completed")
        }
    }

    // MARK: - Shield Icon (matching app icon style)

    private var shieldIcon: some View {
        ZStack {
            // High-end Glow
            Image("LuxuriousShield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)
                .blur(radius: 40)
                .opacity(glowOpacity)

            Image("LuxuriousShield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.aegisGoldMid.opacity(0.4), radius: 25, y: 15)
                .rotationEffect(.degrees(rotationDegrees))
        }
    }

    // MARK: - Grid Overlay

    private var gridOverlay: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 40
            let lineWidth: CGFloat = 0.5

            // Vertical lines
            for x in stride(from: 0, through: size.width, by: gridSize) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.aegisGoldMid), lineWidth: lineWidth)
            }

            // Horizontal lines
            for y in stride(from: 0, through: size.height, by: gridSize) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.aegisGoldMid), lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView()
        .environment(\.navigationCoordinator, NavigationCoordinator())
        .environment(\.authenticationService, AuthenticationService())
}
