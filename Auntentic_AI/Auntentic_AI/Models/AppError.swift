//
//  AppError.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 18: Unified error handling with user-friendly messages
//

import Foundation
import SwiftUI

/// Unified error type for the app with user-friendly messages
enum AppError: LocalizedError, Equatable {

    // MARK: - Network Errors

    /// No internet connection
    case noInternet

    /// Request timed out
    case timeout

    /// Server error (5xx)
    case serverError(Int)

    /// Too many requests (rate limited)
    case rateLimited

    // MARK: - Authentication Errors

    /// User not authenticated
    case notAuthenticated

    /// Session expired
    case sessionExpired

    /// Apple Sign-In failed
    case appleSignInFailed(String)

    /// Email sign-in failed
    case emailSignInFailed(String)

    // MARK: - Upload Errors

    /// Image compression failed
    case compressionFailed

    /// Upload failed
    case uploadFailed(String)

    /// Image quality too low
    case poorImageQuality

    // MARK: - AI Authentication Errors

    /// AI analysis failed
    case aiAnalysisFailed(String)

    /// AI analysis timed out
    case aiTimeout

    // MARK: - Database Errors

    /// Failed to save data
    case saveFailed(String)

    /// Failed to load data
    case loadFailed(String)

    // MARK: - Credit/Purchase Errors

    /// Not enough credits
    case insufficientCredits

    /// Purchase failed
    case purchaseFailed(String)

    /// Purchase pending approval
    case purchasePending

    // MARK: - Generic Errors

    /// Unknown error
    case unknown

    /// Custom error with message
    case custom(String)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No Internet Connection"
        case .timeout:
            return "Request Timed Out"
        case .serverError(let code):
            return "Server Error (\(code))"
        case .rateLimited:
            return "Too Many Requests"
        case .notAuthenticated:
            return "Not Signed In"
        case .sessionExpired:
            return "Session Expired"
        case .appleSignInFailed(let reason):
            return "Apple Sign-In Failed: \(reason)"
        case .emailSignInFailed(let reason):
            return "Sign-In Failed: \(reason)"
        case .compressionFailed:
            return "Image Compression Failed"
        case .uploadFailed(let reason):
            return "Upload Failed: \(reason)"
        case .poorImageQuality:
            return "Image Quality Too Low"
        case .aiAnalysisFailed(let reason):
            return "AI Analysis Failed: \(reason)"
        case .aiTimeout:
            return "AI Analysis Timed Out"
        case .saveFailed(let reason):
            return "Save Failed: \(reason)"
        case .loadFailed(let reason):
            return "Load Failed: \(reason)"
        case .insufficientCredits:
            return "No Credits Available"
        case .purchaseFailed(let reason):
            return "Purchase Failed: \(reason)"
        case .purchasePending:
            return "Purchase Pending Approval"
        case .unknown:
            return "Something Went Wrong"
        case .custom(let message):
            return message
        }
    }

    /// User-friendly recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .noInternet:
            return "Please check your internet connection and try again."
        case .timeout:
            return "The request took too long. Please try again."
        case .serverError:
            return "Our servers are experiencing issues. Please try again later."
        case .rateLimited:
            return "Please wait a moment before trying again."
        case .notAuthenticated, .sessionExpired:
            return "Please sign in again to continue."
        case .appleSignInFailed, .emailSignInFailed:
            return "Please try signing in again."
        case .compressionFailed:
            return "Please try with a different photo."
        case .uploadFailed:
            return "Please check your connection and try again."
        case .poorImageQuality:
            return "Please retake the photo with better lighting and focus."
        case .aiAnalysisFailed:
            return "Please try again. If the problem persists, try with different photos."
        case .aiTimeout:
            return "The AI took too long to respond. Please try again."
        case .saveFailed, .loadFailed:
            return "Please try again. Your data may not have been saved."
        case .insufficientCredits:
            return "Purchase a credit pack to continue checking sneakers."
        case .purchaseFailed, .purchasePending:
            return "Please try again or contact support."
        case .unknown:
            return "Please try again. If the problem persists, contact support."
        case .custom:
            return "Please try again."
        }
    }

    /// Whether this error should trigger a retry
    var isRetryable: Bool {
        switch self {
        case .noInternet, .timeout, .serverError, .rateLimited,
             .uploadFailed, .aiAnalysisFailed, .aiTimeout,
             .saveFailed, .loadFailed:
            return true
        case .notAuthenticated, .sessionExpired, .appleSignInFailed,
             .emailSignInFailed, .compressionFailed, .poorImageQuality,
             .insufficientCredits, .purchaseFailed, .purchasePending,
             .unknown, .custom:
            return false
        }
    }

    /// Icon for the error
    var icon: String {
        switch self {
        case .noInternet:
            return "wifi.slash"
        case .timeout, .aiTimeout:
            return "clock.badge.exclamationmark"
        case .serverError, .rateLimited:
            return "server.rack"
        case .notAuthenticated, .sessionExpired:
            return "person.crop.circle.badge.exclamationmark"
        case .appleSignInFailed, .emailSignInFailed:
            return "lock.shield"
        case .compressionFailed, .uploadFailed:
            return "arrow.up.circle.badge.xmark"
        case .poorImageQuality:
            return "photo.badge.exclamationmark"
        case .aiAnalysisFailed:
            return "sparkles"
        case .saveFailed, .loadFailed:
            return "externaldrive.badge.exclamationmark"
        case .insufficientCredits:
            return "sparkles"
        case .purchaseFailed, .purchasePending:
            return "creditcard.trianglebadge.exclamationmark"
        case .unknown, .custom:
            return "exclamationmark.triangle"
        }
    }

    /// Color for the error
    var color: Color {
        switch self {
        case .noInternet, .timeout, .serverError:
            return .orange
        case .rateLimited:
            return .yellow
        case .notAuthenticated, .sessionExpired:
            return .blue
        case .poorImageQuality:
            return .purple
        case .insufficientCredits:
            return .orange
        case .purchaseFailed, .purchasePending:
            return .red
        default:
            return .red
        }
    }

    // MARK: - Equatable

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }

    // MARK: - Factory Methods

    /// Convert any error to AppError
    static func from(_ error: Error) -> AppError {
        // Already an AppError
        if let appError = error as? AppError {
            return appError
        }

        // Timeout errors from AsyncTimeout utility
        if error is TimeoutError {
            return .aiTimeout
        }

        // URL errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternet
            case .timedOut:
                return .timeout
            default:
                return .custom(urlError.localizedDescription)
            }
        }

        // NSError with HTTP status
        if let nsError = error as NSError? {
            if nsError.code >= 500 && nsError.code < 600 {
                return .serverError(nsError.code)
            }
            if nsError.code == 429 {
                return .rateLimited
            }
        }

        // Existing error types
        if let uploadError = error as? UploadError {
            switch uploadError {
            case .noAuthenticatedUser:
                return .notAuthenticated
            case .compressionFailed:
                return .compressionFailed
            case .uploadFailed(_, let underlyingError):
                return .uploadFailed(underlyingError.localizedDescription)
            default:
                return .custom(uploadError.localizedDescription)
            }
        }

        if let authError = error as? SneakerAuthenticationError {
            switch authError {
            case .noActiveSession:
                return .sessionExpired
            case .networkError(let underlyingError):
                return AppError.from(underlyingError)
            default:
                return .aiAnalysisFailed(authError.localizedDescription)
            }
        }

        if let historyError = error as? AuthHistoryError {
            switch historyError {
            case .noActiveSession:
                return .sessionExpired
            case .databaseError(let underlyingError):
                return .saveFailed(underlyingError.localizedDescription)
            }
        }

        if let creditError = error as? CreditError {
            switch creditError {
            case .cancelled:
                return .custom("Purchase was cancelled")
            case .pending:
                return .purchasePending
            case .insufficientCredits:
                return .insufficientCredits
            case .verificationFailed(let underlyingError):
                return .purchaseFailed(underlyingError.localizedDescription)
            case .syncFailed(let underlyingError):
                return .saveFailed(underlyingError.localizedDescription)
            case .noSession:
                return .sessionExpired
            case .unknown:
                return .purchaseFailed("Unknown error")
            }
        }

        // Generic fallback
        return .custom(error.localizedDescription)
    }
}
