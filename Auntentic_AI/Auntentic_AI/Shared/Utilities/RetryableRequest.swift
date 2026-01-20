//
//  RetryableRequest.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 18: Retry logic for network resilience
//

import Foundation
import OSLog

/// Utility for executing retryable async operations with exponential backoff
enum RetryableRequest {

    private static let logger = Logger(subsystem: "com.checkkicks.app", category: "Retry")

    /// Configuration for retry behavior
    struct Configuration {
        /// Maximum number of retry attempts (not including initial attempt)
        let maxRetries: Int

        /// Initial delay before first retry (in seconds)
        let initialDelay: TimeInterval

        /// Maximum delay between retries (in seconds)
        let maxDelay: TimeInterval

        /// Multiplier for exponential backoff
        let backoffMultiplier: Double

        /// Whether to add jitter to retry delays
        let useJitter: Bool

        /// Default configuration
        static let `default` = Configuration(
            maxRetries: 3,
            initialDelay: 1.0,
            maxDelay: 30.0,
            backoffMultiplier: 2.0,
            useJitter: true
        )

        /// Configuration for quick retries (for minor network hiccups)
        static let quick = Configuration(
            maxRetries: 2,
            initialDelay: 0.5,
            maxDelay: 5.0,
            backoffMultiplier: 2.0,
            useJitter: true
        )

        /// Configuration for critical operations (more patient)
        static let patient = Configuration(
            maxRetries: 5,
            initialDelay: 2.0,
            maxDelay: 60.0,
            backoffMultiplier: 2.0,
            useJitter: true
        )
    }

    /// Execute an async operation with retry logic
    /// - Parameters:
    ///   - configuration: Retry configuration
    ///   - shouldRetry: Closure to determine if an error should trigger a retry
    ///   - operation: The async operation to execute
    /// - Returns: The result of the operation
    static func execute<T>(
        configuration: Configuration = .default,
        shouldRetry: @escaping (Error) -> Bool = { _ in true },
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        var currentDelay = configuration.initialDelay

        for attempt in 0...configuration.maxRetries {
            do {
                if attempt > 0 {
                    logger.info("🔄 Retry attempt \(attempt)/\(configuration.maxRetries)")
                }

                let result = try await operation()

                if attempt > 0 {
                    logger.info("✅ Operation succeeded after \(attempt) retry(ies)")
                }

                return result

            } catch {
                lastError = error
                logger.warning("⚠️ Attempt \(attempt + 1) failed: \(error.localizedDescription)")

                // Check if we should retry
                guard attempt < configuration.maxRetries else {
                    logger.error("❌ All retry attempts exhausted")
                    break
                }

                guard shouldRetry(error) else {
                    logger.info("🛑 Error is not retryable, giving up")
                    break
                }

                // Check network connectivity before retrying
                if !NetworkMonitor.shared.isConnected {
                    logger.info("📡 Waiting for network connection...")
                    let connected = await NetworkMonitor.shared.waitForConnection(timeout: 10)
                    if !connected {
                        logger.error("❌ Network connection timeout")
                        throw AppError.noInternet
                    }
                }

                // Calculate delay with optional jitter
                var delay = min(currentDelay, configuration.maxDelay)
                if configuration.useJitter {
                    // Add 0-25% jitter
                    delay *= (1.0 + Double.random(in: 0...0.25))
                }

                logger.info("⏳ Waiting \(String(format: "%.1f", delay))s before retry...")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                // Increase delay for next attempt
                currentDelay *= configuration.backoffMultiplier
            }
        }

        throw lastError ?? AppError.unknown
    }

    /// Check if an error is retryable
    /// - Parameter error: The error to check
    /// - Returns: Whether the error should trigger a retry
    static func isRetryable(_ error: Error) -> Bool {
        // Network errors are retryable
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .networkConnectionLost,
                 .notConnectedToInternet,
                 .dnsLookupFailed,
                 .httpTooManyRedirects,
                 .resourceUnavailable,
                 .secureConnectionFailed:
                return true
            default:
                return false
            }
        }

        // Check for transient server errors (5xx)
        if let nsError = error as NSError? {
            if nsError.domain == NSURLErrorDomain {
                return true
            }
            // HTTP 5xx errors are retryable
            if nsError.code >= 500 && nsError.code < 600 {
                return true
            }
        }

        // App-specific retryable errors
        if let appError = error as? AppError {
            return appError.isRetryable
        }

        return false
    }
}
