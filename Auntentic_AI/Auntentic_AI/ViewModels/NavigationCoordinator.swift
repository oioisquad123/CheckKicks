//
//  NavigationCoordinator.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Task 5: MVVM Navigation Coordinator
//

import SwiftUI
import OSLog

/// Navigation coordinator using @Observable for iOS 17+
/// Manages navigation state and flow throughout the app
@Observable
final class NavigationCoordinator {
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "Navigation")
    // MARK: - Navigation Path
    var path: NavigationPath = NavigationPath()

    // MARK: - Navigation Destinations
    enum Destination: Hashable {
        case splash
        case onboarding
        case auth
        case home
        case photoCapture
        case history
    }

    // MARK: - Current Screen
    var currentDestination: Destination = .splash

    // MARK: - Navigation Methods

    /// Navigate to a specific destination
    func navigate(to destination: Destination) {
        logger.info("🧭 Navigating to: \(String(describing: destination))")
        logger.info("📍 Current path count: \(self.path.count)")
        currentDestination = destination
        path.append(destination)
        logger.info("📍 New path count: \(self.path.count)")
    }

    /// Navigate to Home (after successful authentication)
    func navigateToHome() {
        logger.info("🏠 Navigating to Home")
        navigate(to: .home)
    }

    /// Navigate to Auth screen
    func navigateToAuth() {
        logger.info("🔐 Navigating to Auth")
        navigate(to: .auth)
    }

    /// Navigate to Onboarding screen
    func navigateToOnboarding() {
        logger.info("📚 Navigating to Onboarding")
        navigate(to: .onboarding)
    }

    /// Navigate to Photo Capture wizard
    func navigateToPhotoCapture() {
        logger.info("📸 Navigating to Photo Capture")
        navigate(to: .photoCapture)
    }

    /// Navigate to History screen
    func navigateToHistory() {
        logger.info("📜 Navigating to History")
        navigate(to: .history)
    }

    /// Pop to root
    func popToRoot() {
        logger.info("⬅️ Popping to root (removing \(self.path.count) items)")
        path.removeLast(path.count)
        currentDestination = .splash
    }

    /// Navigate back to home (clears navigation stack and goes to home)
    func navigateBackToHome() {
        logger.info("🏠 Navigating back to home (clearing stack)")
        path.removeLast(path.count)
        currentDestination = .home
    }

    /// Start a new authentication check (clears stack and goes directly to photo capture)
    func startNewCheck() {
        logger.info("🔄 Starting new check (clearing stack and navigating to photo capture)")
        path.removeLast(path.count)
        currentDestination = .photoCapture
        path.append(Destination.photoCapture)
        logger.info("📍 New path count: \(self.path.count)")
    }

    /// Pop one level back
    func pop() {
        if !path.isEmpty {
            logger.info("⬅️ Popping one level back")
            path.removeLast()
        } else {
            logger.info("⚠️ Cannot pop - path is empty")
        }
    }
}
