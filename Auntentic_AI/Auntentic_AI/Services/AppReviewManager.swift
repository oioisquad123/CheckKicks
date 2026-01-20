//
//  AppReviewManager.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/19/26.
//  Handles App Store rating prompts and TestFlight feedback
//

import SwiftUI
import StoreKit
import UIKit

/// Manages app review requests and TestFlight feedback
/// - App Store: Uses SKStoreReviewController (submits real ratings)
/// - TestFlight: Shows preview dialog (no submission)
/// - Development: Shows dialog for testing
@Observable
final class AppReviewManager {

    // MARK: - Constants

    /// Number of successful authentications before prompting for review
    private let reviewPromptThreshold = 3

    /// Key for storing successful auth count in UserDefaults
    private let successfulAuthCountKey = "successfulAuthenticationCount"

    /// Key for storing last review prompt date
    private let lastReviewPromptKey = "lastReviewPromptDate"

    /// Minimum days between review prompts
    private let minimumDaysBetweenPrompts = 90

    /// Support email address
    let supportEmail = "support@checkkicks.app"

    /// App Store ID (update this after app is published)
    private let appStoreID = "YOUR_APP_STORE_ID"

    // MARK: - Environment Detection

    /// Detects if the app is running in TestFlight
    var isTestFlight: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }

    /// Detects if running in debug/simulator
    var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Returns the current environment as a string
    var currentEnvironment: String {
        if isDebug {
            return "Development"
        } else if isTestFlight {
            return "TestFlight"
        } else {
            return "App Store"
        }
    }

    // MARK: - Review Prompt Logic

    /// Records a successful authentication and potentially prompts for review
    /// Call this after a high-confidence authentication result
    func recordSuccessfulAuthentication() {
        let currentCount = UserDefaults.standard.integer(forKey: successfulAuthCountKey)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: successfulAuthCountKey)

        // Check if we should prompt for review
        if shouldPromptForReview(authCount: newCount) {
            requestReview()
        }
    }

    /// Determines if we should prompt for review based on auth count and timing
    private func shouldPromptForReview(authCount: Int) -> Bool {
        // Only prompt at threshold intervals (3, 6, 9, etc.)
        guard authCount > 0 && authCount % reviewPromptThreshold == 0 else {
            return false
        }

        // Check if enough time has passed since last prompt
        if let lastPromptDate = UserDefaults.standard.object(forKey: lastReviewPromptKey) as? Date {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPromptDate, to: Date()).day ?? 0
            if daysSinceLastPrompt < minimumDaysBetweenPrompts {
                return false
            }
        }

        return true
    }

    /// Requests an app review using StoreKit
    /// - Note: This same code works in all environments:
    ///   - TestFlight: Shows dialog preview, doesn't submit
    ///   - App Store: Shows real dialog, submits rating
    ///   - Development: Shows dialog for testing
    func requestReview() {
        // Record that we prompted
        UserDefaults.standard.set(Date(), forKey: lastReviewPromptKey)

        // Request review using StoreKit
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    /// Opens the App Store page for rating (fallback when SKStoreReviewController limit reached)
    func openAppStoreForRating() {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Feedback Email

    /// Creates a feedback email URL with pre-filled device information
    /// - Returns: A URL for the mailto link, or nil if encoding fails
    func feedbackEmailURL() -> URL? {
        let subject = "Auntentic Feedback (\(currentEnvironment))"
        let appVersion = Bundle.main.appVersionString
        let body = """


---
App Version: \(appVersion)
Environment: \(currentEnvironment)
Device: \(deviceModelName)
iOS Version: \(UIDevice.current.systemVersion)
"""

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""

        return URL(string: "mailto:\(supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)")
    }

    /// Gets device model identifier
    private var deviceModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    // MARK: - Reset (for testing)

    /// Resets all review-related data (useful for testing)
    func resetReviewData() {
        UserDefaults.standard.removeObject(forKey: successfulAuthCountKey)
        UserDefaults.standard.removeObject(forKey: lastReviewPromptKey)
    }

    /// Gets the current successful authentication count (for debugging)
    var successfulAuthCount: Int {
        UserDefaults.standard.integer(forKey: successfulAuthCountKey)
    }
}

// MARK: - Environment Key

private struct AppReviewManagerKey: EnvironmentKey {
    static let defaultValue = AppReviewManager()
}

extension EnvironmentValues {
    var appReviewManager: AppReviewManager {
        get { self[AppReviewManagerKey.self] }
        set { self[AppReviewManagerKey.self] = newValue }
    }
}

// MARK: - Bundle Extension

private extension Bundle {
    var appVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
