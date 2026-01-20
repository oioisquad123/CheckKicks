//
//  AppleSignInCoordinator.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Task 6: Apple Sign-In Coordinator
//

import Foundation
import AuthenticationServices
import OSLog

/// Coordinator for Apple Sign-In flow
/// Handles ASAuthorizationController delegate callbacks
@MainActor
class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    // MARK: - Properties

    private let authService: AuthenticationService
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "AppleSignIn")

    /// Completion handler called when sign-in completes (success or failure)
    var onCompletion: ((Result<Void, Error>) -> Void)?

    // MARK: - Initialization

    init(authService: AuthenticationService) {
        self.authService = authService
        super.init()
    }

    // MARK: - Public Methods

    /// Start Apple Sign-In flow
    func startSignInFlow() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

        logger.info("Apple Sign-In flow started")
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            do {
                try await authService.signInWithApple(authorization: authorization)
                onCompletion?(.success(()))
                logger.info("Apple Sign-In authorization completed successfully")
            } catch {
                onCompletion?(.failure(error))
                logger.error("Apple Sign-In authorization failed: \(error.localizedDescription)")
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onCompletion?(.failure(error))
        logger.error("Apple Sign-In error: \(error.localizedDescription)")
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the key window for presenting the Apple Sign-In sheet
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window available for presenting Apple Sign-In")
        }
        return window
    }
}
