//
//  GoogleSignInCoordinator.swift
//  Auntentic_AI
//
//  Created for Google Sign-In integration
//  January 16, 2026
//

import Foundation
import GoogleSignIn
import OSLog

/// Coordinator for Google Sign-In flow
/// Handles GIDSignIn callbacks and Supabase integration
@MainActor
class GoogleSignInCoordinator: NSObject {

    // MARK: - Properties

    private let authService: AuthenticationService
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "GoogleSignIn")

    /// Completion handler called when sign-in completes (success or failure)
    var onCompletion: ((Result<Void, Error>) -> Void)?

    // MARK: - Initialization

    init(authService: AuthenticationService) {
        self.authService = authService
        super.init()
    }

    // MARK: - Public Methods

    /// Start Google Sign-In flow
    func startSignInFlow() {
        logger.info("Google Sign-In flow started")

        // Get the presenting view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            logger.error("No window available for presenting Google Sign-In")
            onCompletion?(.failure(GoogleSignInError.noViewController))
            return
        }

        // Get the topmost view controller
        var presentingController = rootViewController
        while let presented = presentingController.presentedViewController {
            presentingController = presented
        }

        Task {
            do {
                // Perform Google Sign-In
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingController)

                guard let idToken = result.user.idToken?.tokenString else {
                    throw GoogleSignInError.missingIdToken
                }

                let accessToken = result.user.accessToken.tokenString

                logger.info("Google Sign-In credentials received, authenticating with Supabase...")

                // Sign in with Supabase using Google tokens
                try await authService.signInWithGoogle(idToken: idToken, accessToken: accessToken)

                onCompletion?(.success(()))
                logger.info("Google Sign-In completed successfully")

            } catch let error as GIDSignInError where error.code == .canceled {
                // User cancelled - don't treat as error
                logger.info("Google Sign-In cancelled by user")
                onCompletion?(.failure(GoogleSignInError.cancelled))

            } catch {
                logger.error("Google Sign-In error: \(error.localizedDescription)")
                onCompletion?(.failure(error))
            }
        }
    }
}

// MARK: - Google Sign-In Errors

enum GoogleSignInError: LocalizedError {
    case noViewController
    case missingIdToken
    case cancelled

    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "Unable to present Google Sign-In"
        case .missingIdToken:
            return "Failed to get identity token from Google"
        case .cancelled:
            return "Sign-in was cancelled"
        }
    }
}
