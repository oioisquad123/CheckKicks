//
//  Auntentic_AIApp.swift
//  Auntentic_AI
//
//  Created by Bayu Hidayat on 12/25/25.
//  Updated: Session persistence with timeout handling - Dec 26, 2025
//  Updated: Deep link handling for email auth callbacks - Jan 3, 2026
//  Updated: StoreKit 2 credit manager integration - Jan 10, 2026
//

import SwiftUI
import Supabase
import StoreKit
import OSLog
import GoogleSignIn

@main
struct Auntentic_AIApp: App {
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "AppLifecycle")
    // Navigation coordinator using @Observable (iOS 17+)
    @State private var coordinator = NavigationCoordinator()

    // Authentication service using @Observable (iOS 17+)
    @State private var authService = AuthenticationService()

    // Image upload service using @Observable (iOS 17+)
    @State private var uploadService = ImageUploadService()

    // Authentication history service using @Observable (iOS 17+)
    @State private var authHistoryService = AuthenticationHistoryService()

    // Credit manager for StoreKit 2 purchases (iOS 17+)
    @State private var creditManager = CreditManager()

    // App review manager for rating prompts and feedback (iOS 17+)
    @State private var appReviewManager = AppReviewManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                // Start with SplashView - it will check session and navigate appropriately
                SplashView()
                    .navigationDestination(for: NavigationCoordinator.Destination.self) { destination in
                        switch destination {
                        case .splash:
                            SplashView()
                        case .onboarding:
                            OnboardingView()
                        case .auth:
                            AuthView()
                        case .home:
                            HomeView()
                        case .photoCapture:
                            PhotoCaptureWizardView()
                        case .history:
                            HistoryView()
                        }
                    }
            }
            .environment(\.navigationCoordinator, coordinator)
            .environment(\.authenticationService, authService)
            .environment(\.imageUploadService, uploadService)
            .environment(\.authHistoryService, authHistoryService)
            .environment(\.creditManager, creditManager)
            .environment(\.appReviewManager, appReviewManager)
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .task {
                // Load StoreKit products and user credits on app launch
                await creditManager.loadProducts()
                await creditManager.loadCredits()
            }
        }
    }

    // MARK: - Deep Link Handling

    /// Handle incoming deep links for auth callbacks (email confirmation, password reset, Google Sign-In, etc.)
    private func handleDeepLink(_ url: URL) {
        // Handle Google Sign-In URL callback first
        if GIDSignIn.sharedInstance.handle(url) {
            logger.info("URL handled by Google Sign-In")
            return
        }

        // Handle Supabase auth callback URLs (email confirmation, password reset)
        Task {
            do {
                // Let Supabase handle the auth callback URL
                let session = try await SupabaseClientManager.shared.auth.session(from: url)
                await MainActor.run {
                    authService.currentUser = session.user
                    // Navigate to home after successful auth
                    coordinator.navigateToHome()
                }
            } catch {
                logger.error("Deep link auth error: \(error.localizedDescription)")
                // If deep link fails, user may need to try again or sign in manually
            }
        }
    }
}
