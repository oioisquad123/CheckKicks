//
//  SneakerAuthenticationService.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/29/25.
//  Task 11: Service for authenticating sneakers via OpenAI Vision API
//

import Foundation
import SwiftUI
import Supabase
import OSLog

/// Service for authenticating sneakers using OpenAI GPT-4o Vision API
@Observable
final class SneakerAuthenticationService {

    // MARK: - Properties

    /// Current authentication status
    var authenticationStatus: AuthStatus = .idle

    /// Authentication result
    var result: AuthenticationResult?

    /// Last error
    var lastError: Error?

    private let logger = Logger(subsystem: "com.checkkicks.app", category: "SneakerAuth")
    private let supabase = SupabaseClientManager.shared

    // MARK: - Authentication Status

    enum AuthStatus: Equatable {
        case idle
        case authenticating
        case completed
        case failed(Error)

        static func == (lhs: AuthStatus, rhs: AuthStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.authenticating, .authenticating),
                 (.completed, .completed):
                return true
            case (.failed, .failed):
                return true
            default:
                return false
            }
        }

        var description: String {
            switch self {
            case .idle:
                return "Ready to authenticate"
            case .authenticating:
                return "Analyzing sneakers with AI..."
            case .completed:
                return "Authentication complete"
            case .failed(let error):
                return "Authentication failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Authentication Methods

    /// Authenticate sneakers using uploaded image URLs
    /// - Parameter imageURLs: Array of signed URLs for the uploaded images
    /// - Returns: Authentication result from OpenAI Vision API
    @MainActor
    func authenticate(imageURLs: [URL]) async throws -> AuthenticationResult {
        guard imageURLs.count == 6 else {
            throw SneakerAuthenticationError.invalidImageCount(imageURLs.count)
        }

        // Check network connectivity before starting
        guard NetworkMonitor.shared.isConnected else {
            logger.error("❌ No internet connection")
            throw AppError.noInternet
        }

        logger.info("🔍 Starting authentication with \(imageURLs.count) images")
        authenticationStatus = .authenticating
        lastError = nil

        do {
            // Get the current session token
            guard let session = try? await supabase.auth.session else {
                logger.error("❌ No active session found")
                throw SneakerAuthenticationError.noActiveSession
            }

            let accessToken = session.accessToken
            #if DEBUG
            logger.debug("🔑 Session token acquired (length: \(accessToken.count))")
            #endif

            // Prepare request payload
            struct AuthenticationRequest: Encodable {
                let imageUrls: [String]
            }

            let payload = AuthenticationRequest(
                imageUrls: imageURLs.map { $0.absoluteString }
            )

            // Get anon key from Config.plist via SupabaseClientManager
            let anonKey = SupabaseClientManager.anonKey

            logger.info("📤 Calling Edge Function with both apikey and Authorization headers...")

            // Call Edge Function with timeout and retry logic for network resilience
            // Timeout: 120 seconds (2 minutes) for the entire operation including retries
            let result: AuthenticationResult = try await withTimeout(seconds: 120) {
                try await RetryableRequest.execute(
                    configuration: .patient, // More retries for AI calls (they can take a while)
                    shouldRetry: RetryableRequest.isRetryable
                ) {
                    try await self.supabase.functions
                        .invoke(
                            "authenticate-sneaker",
                            options: FunctionInvokeOptions(
                                headers: [
                                    "apikey": anonKey,
                                    "Authorization": "Bearer \(anonKey)"
                                ],
                                body: payload
                            )
                        )
                }
            }

            logger.info("📥 Received response from Edge Function")

            await MainActor.run {
                self.result = result
                self.authenticationStatus = .completed
                logger.info("✅ Analysis complete: \(result.confidenceLevel.displayName) (\(result.confidenceScore)%)")
            }

            return result

        } catch {
            await MainActor.run {
                self.lastError = error
                self.authenticationStatus = .failed(error)
                logger.error("❌ Authentication failed: \(error.localizedDescription)")
            }
            throw error
        }
    }

    /// Reset authentication state
    @MainActor
    func reset() {
        authenticationStatus = .idle
        result = nil
        lastError = nil
        logger.info("🔄 Sneaker authentication service reset")
    }
}

// MARK: - Authentication Errors

enum SneakerAuthenticationError: LocalizedError {
    case invalidImageCount(Int)
    case noActiveSession
    case networkError(Error)
    case parsingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImageCount(let count):
            return "Expected 6 images, got \(count)"
        case .noActiveSession:
            return "No active session. Please sign in again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}

// MARK: - Environment Key

private struct SneakerAuthenticationServiceKey: EnvironmentKey {
    static let defaultValue = SneakerAuthenticationService()
}

extension EnvironmentValues {
    var sneakerAuthService: SneakerAuthenticationService {
        get { self[SneakerAuthenticationServiceKey.self] }
        set { self[SneakerAuthenticationServiceKey.self] = newValue }
    }
}
