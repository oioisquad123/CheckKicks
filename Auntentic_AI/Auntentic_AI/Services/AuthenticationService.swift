//
//  AuthenticationService.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Task 6: Authentication Service with Apple Sign-In and Email
//

import Foundation
import Supabase
import AuthenticationServices
import OSLog

/// Authentication service wrapping Supabase Auth
/// Handles Apple Sign-In, Email/Password, session persistence, and sign out
@Observable
final class AuthenticationService {

    // MARK: - Properties

    /// Current authenticated user
    var currentUser: User?

    /// Authentication state
    var isAuthenticated: Bool {
        currentUser != nil
    }

    /// Loading state for UI feedback
    var isLoading: Bool = false

    /// Session check state
    var isCheckingSession: Bool = true

    /// Last authentication error
    var lastError: Error?

    /// Track if user just signed in (prevents session check from clearing fresh auth)
    private var justSignedIn: Bool = false

    /// Timestamp of last successful sign-in
    private var lastSignInTime: Date?

    /// Flag to indicate sign-in is in progress (prevents race condition with session check)
    private var isSigningIn: Bool = false

    /// Logger for debugging and error tracking
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "Authentication")

    /// Supabase client instance
    private let supabase = SupabaseClientManager.shared

    // MARK: - Initialization

    init() {
        // DO NOT check session on init - it can hang
        // Session check will happen when SplashView appears
        logger.info("✅ AuthenticationService initialized")
    }

    // MARK: - Session Management

    /// Check for existing session (persisted across app launches)
    /// Supabase automatically handles token refresh
    /// Uses timeout to prevent hanging
    @MainActor
    func checkExistingSession() async {
        logger.info("🔍 Starting session check...")
        isCheckingSession = true

        // If sign-in is in progress, skip session check to prevent race condition
        if isSigningIn {
            logger.info("⏭️ Skipping session check - sign-in in progress")
            isCheckingSession = false
            return
        }

        // If user just signed in (within last 10 seconds), skip session check
        if let lastSignIn = lastSignInTime, Date().timeIntervalSince(lastSignIn) < 10 {
            logger.info("⏭️ Skipping session check - user just signed in \(Date().timeIntervalSince(lastSignIn))s ago")
            isCheckingSession = false
            return
        }

        do {
            logger.info("⏱️ Calling supabase.auth.session with 5s timeout...")
            // Wrap session check with 5-second timeout to prevent hanging
            let session = try await withTimeout(seconds: 5) {
                try await self.supabase.auth.session
            }
            currentUser = session.user
            logger.info("✅ Existing session found for user: \(session.user.id)")
        } catch is TimeoutError {
            // Session check timed out
            logger.warning("⏰ Session check timed out after 5 seconds")
            // Only clear currentUser if we didn't just sign in
            if !justSignedIn {
                logger.warning("❌ Clearing currentUser due to timeout")
                currentUser = nil
            } else {
                logger.info("✋ Keeping currentUser despite timeout (just signed in)")
            }
        } catch {
            // No existing session - user needs to sign in
            logger.info("ℹ️ No existing session found: \(error.localizedDescription)")
            // Only clear currentUser if we didn't just sign in
            if !justSignedIn {
                logger.info("❌ Clearing currentUser - no session")
                currentUser = nil
            } else {
                logger.info("✋ Keeping currentUser despite error (just signed in)")
            }
        }

        isCheckingSession = false
        // Clear the justSignedIn flag after session check completes
        justSignedIn = false
        logger.info("🏁 Session check complete. isAuthenticated: \(self.isAuthenticated)")
    }

    /// Get current session
    func getSession() async throws -> Session {
        return try await supabase.auth.session
    }

    // MARK: - Apple Sign-In

    /// Sign in with Apple using ASAuthorizationAppleIDProvider
    /// Primary authentication method for the app
    @MainActor
    func signInWithApple(authorization: ASAuthorization) async throws {
        logger.info("🍎 Starting Apple Sign-In...")
        isSigningIn = true
        defer { isSigningIn = false }
        isLoading = true
        lastError = nil

        do {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw AuthenticationError.invalidCredential
            }

            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                throw AuthenticationError.missingIdentityToken
            }

            // Sign in with Supabase using Apple identity token
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: identityToken
                )
            )

            currentUser = session.user
            justSignedIn = true
            lastSignInTime = Date()
            logger.info("✅ Apple Sign-In successful for user: \(session.user.id)")

        } catch {
            logger.error("❌ Apple Sign-In failed: \(error.localizedDescription)")
            lastError = error
            throw error
        }

        isLoading = false
    }

    // MARK: - Google Sign-In

    /// Sign in with Google using GoogleSignIn SDK
    /// Uses OpenID Connect flow with Supabase
    @MainActor
    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        logger.info("🔵 Starting Google Sign-In...")
        isSigningIn = true
        defer { isSigningIn = false }
        isLoading = true
        lastError = nil

        do {
            // Sign in with Supabase using Google identity token
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )

            currentUser = session.user
            justSignedIn = true
            lastSignInTime = Date()
            logger.info("✅ Google Sign-In successful for user: \(session.user.id)")

        } catch {
            logger.error("❌ Google Sign-In failed: \(error.localizedDescription)")
            lastError = error
            throw error
        }

        isLoading = false
    }

    // MARK: - Email/Password Authentication

    /// Sign up with email and password
    @MainActor
    func signUpWithEmail(email: String, password: String) async throws {
        logger.info("📧 Starting email sign-up for: \(email)")
        isSigningIn = true
        defer { isSigningIn = false }
        isLoading = true
        lastError = nil

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            currentUser = response.user
            justSignedIn = true
            lastSignInTime = Date()
            logger.info("✅ Email sign-up successful for: \(email)")

        } catch {
            logger.error("❌ Email sign-up failed: \(error.localizedDescription)")
            lastError = error
            throw error
        }

        isLoading = false
    }

    /// Sign in with email and password
    @MainActor
    func signInWithEmail(email: String, password: String) async throws {
        logger.info("📧 Starting email sign-in for: \(email)")
        isSigningIn = true
        defer { isSigningIn = false }
        isLoading = true
        lastError = nil

        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )

            currentUser = session.user
            justSignedIn = true
            lastSignInTime = Date()
            logger.info("✅ Email sign-in successful for: \(email)")

        } catch {
            logger.error("❌ Email sign-in failed: \(error.localizedDescription)")
            lastError = error
            throw error
        }

        isLoading = false
    }

    // MARK: - Sign Out

    /// Sign out and clear all local data
    /// CRITICAL: Clears local cache, Keychain, and invalidates Supabase session (FR-1.4)
    @MainActor
    func signOut() async throws {
        logger.info("🚪 Starting sign out...")
        isLoading = true
        lastError = nil

        do {
            // Sign out from Supabase (clears Keychain and invalidates session)
            try await supabase.auth.signOut()

            // Clear local state
            currentUser = nil
            justSignedIn = false
            lastSignInTime = nil

            logger.info("✅ Sign out successful")

        } catch {
            logger.error("❌ Sign out failed: \(error.localizedDescription)")
            lastError = error
            throw error
        }

        isLoading = false
    }

    // MARK: - Password Reset

    /// Send password reset email
    func resetPassword(email: String) async throws {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            logger.info("Password reset email sent to: \(email)")
        } catch {
            logger.error("Password reset failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - OTP Verification

    /// Verify email signup with OTP code
    @MainActor
    func verifySignUpOTP(email: String, token: String) async throws {
        logger.info("🔢 Verifying signup OTP for: \(email)")
        isSigningIn = true
        defer { isSigningIn = false }
        isLoading = true
        lastError = nil

        do {
            let session = try await supabase.auth.verifyOTP(
                email: email,
                token: token,
                type: .signup
            )

            currentUser = session.user
            justSignedIn = true
            lastSignInTime = Date()
            logger.info("✅ Email verification successful for: \(email)")

        } catch {
            logger.error("❌ OTP verification failed: \(error.localizedDescription)")
            lastError = error
            throw error
        }

        isLoading = false
    }

    /// Verify password reset with OTP code and set new password
    @MainActor
    func verifyPasswordResetOTP(email: String, token: String, newPassword: String) async throws {
        logger.info("🔢 Verifying password reset OTP for: \(email)")
        isSigningIn = true
        defer { isSigningIn = false }
        isLoading = true
        lastError = nil

        do {
            // First verify the OTP to get a session
            let session = try await supabase.auth.verifyOTP(
                email: email,
                token: token,
                type: .recovery
            )

            // Then update the password
            try await supabase.auth.update(user: UserAttributes(password: newPassword))

            currentUser = session.user
            justSignedIn = true
            lastSignInTime = Date()
            logger.info("✅ Password reset successful for: \(email)")

        } catch {
            logger.error("❌ Password reset OTP verification failed: \(error.localizedDescription)")
            lastError = error
            throw error
        }

        isLoading = false
    }

    /// Resend OTP email for signup verification
    func resendSignUpOTP(email: String) async throws {
        logger.info("📧 Resending signup OTP to: \(email)")
        do {
            try await supabase.auth.resend(email: email, type: .signup)
            logger.info("✅ OTP resent to: \(email)")
        } catch {
            logger.error("❌ Failed to resend OTP: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Authentication Errors

enum AuthenticationError: LocalizedError {
    case invalidCredential
    case missingIdentityToken
    case missingGoogleToken
    case sessionExpired
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid authentication credential"
        case .missingIdentityToken:
            return "Missing identity token from Apple"
        case .missingGoogleToken:
            return "Missing identity token from Google"
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
