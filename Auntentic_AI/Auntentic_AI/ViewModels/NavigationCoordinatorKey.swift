//
//  NavigationCoordinatorKey.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Task 5: Environment Key for Navigation Coordinator
//

import SwiftUI

// MARK: - Environment Key

private struct NavigationCoordinatorKey: EnvironmentKey {
    static let defaultValue = NavigationCoordinator()
}

extension EnvironmentValues {
    var navigationCoordinator: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
}
