//
//  AuthView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Updated: January 2, 2026 - Aegis Gold Design System
//

import SwiftUI
import OSLog
import GoogleSignIn

/// Authentication screen with Aegis Gold premium design
/// Supports Apple Sign-In, Google Sign-In, and Email/Password
struct AuthView: View {
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.authenticationService) private var authService

    @State private var appleSignInCoordinator: AppleSignInCoordinator?
    @State private var googleSignInCoordinator: GoogleSignInCoordinator?
    @State private var showEmailSignIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAppeared = false

    private let logger = Logger(subsystem: "com.checkkicks.app", category: "AuthView")

    var body: some View {
        ZStack {
            // Aegis background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            // Subtle shield watermark
            GeometryReader { geo in
                Image("LuxuriousShield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.04)
                    .frame(width: geo.size.width * 0.8)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.35)
            }

            VStack(spacing: 0) {
                Spacer()

                // Logo and Title Section
                logoSection
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : -30)

                Spacer()

                // Authentication Buttons Section
                authButtonsSection
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 30)

                // Loading Indicator
                if authService.isLoading {
                    AegisSpinner()
                        .padding(.top, 24)
                }

                Spacer()

                // Disclaimer
                disclaimerSection
                    .opacity(isAppeared ? 1 : 0)
            }
            .padding(.horizontal, 32)
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isAppeared = true
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView()
                .environment(\.authenticationService, authService)
                .environment(\.navigationCoordinator, coordinator)
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authService.isAuthenticated) { oldValue, newValue in
            logger.info("AuthView: isAuthenticated changed from \(oldValue) to \(newValue)")
            if newValue {
                logger.info("AuthView: User authenticated, navigating to Home")
                coordinator.navigateToHome()
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: 24) {
            // Animated shield icon with gold glow
                Image("LuxuriousShield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: Color.aegisGoldMid.opacity(0.3), radius: 20, y: 8)

            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.aegisGray)

                Text("CheckKicks")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                Text("AI-Powered Sneaker Authentication")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Auth Buttons Section

    private var authButtonsSection: some View {
        VStack(spacing: 16) {
            // Sign In with Apple - Primary gold button (App Store requires Apple first)
            AegisPrimaryButton(title: "Sign in with Apple", icon: "apple.logo") {
                handleAppleSignIn()
            }
            .disabled(authService.isLoading)
            .opacity(authService.isLoading ? 0.6 : 1)

            // Sign In with Google - White button (Google brand guidelines)
            AegisGoogleButton {
                handleGoogleSignIn()
            }
            .disabled(authService.isLoading)
            .opacity(authService.isLoading ? 0.6 : 1)

            // OR Divider
            HStack(spacing: 16) {
                Rectangle()
                    .fill(Color.aegisMuted)
                    .frame(height: 1)

                Text("or")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.aegisMuted)

                Rectangle()
                    .fill(Color.aegisMuted)
                    .frame(height: 1)
            }
            .padding(.vertical, 8)

            // Sign In with Email - Underlined text link
            Button(action: {
                HapticManager.lightImpact()
                showEmailSignIn = true
            }) {
                Text("Sign in with Email")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.aegisGoldMid)
                    .underline()
            }
            .frame(height: 44) // Ensure accessible touch target
            .disabled(authService.isLoading)
            .opacity(authService.isLoading ? 0.6 : 1)
        }
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        Text("By continuing, you agree to our Terms of Service and Privacy Policy")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.aegisMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
    }

    // MARK: - Actions

    private func handleAppleSignIn() {
        HapticManager.mediumImpact()
        let appleCoordinator = AppleSignInCoordinator(authService: authService)
        appleCoordinator.onCompletion = { result in
            switch result {
            case .success:
                HapticManager.success()
                // Navigate to home directly - don't rely on onChange observer
                self.coordinator.navigateToHome()
            case .failure(let error):
                HapticManager.error()
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        appleSignInCoordinator = appleCoordinator
        appleCoordinator.startSignInFlow()
    }

    private func handleGoogleSignIn() {
        HapticManager.mediumImpact()
        let googleCoordinator = GoogleSignInCoordinator(authService: authService)
        googleCoordinator.onCompletion = { result in
            switch result {
            case .success:
                HapticManager.success()
                // Navigate to home directly - don't rely on onChange observer
                self.coordinator.navigateToHome()
            case .failure(let error):
                // Don't show error for user cancellation
                if let googleError = error as? GoogleSignInError, googleError == .cancelled {
                    // User cancelled - no error message needed
                    return
                }
                HapticManager.error()
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        googleSignInCoordinator = googleCoordinator
        googleCoordinator.startSignInFlow()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AuthView()
            .environment(\.navigationCoordinator, NavigationCoordinator())
            .environment(\.authenticationService, AuthenticationService())
    }
}
