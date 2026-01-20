//
//  AuthenticationHistoryServiceKey.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/30/25.
//  Task 13: Environment Key for Authentication History Service
//

import SwiftUI

// MARK: - Environment Key

private struct AuthenticationHistoryServiceKey: EnvironmentKey {
    static let defaultValue = AuthenticationHistoryService()
}

extension EnvironmentValues {
    var authHistoryService: AuthenticationHistoryService {
        get { self[AuthenticationHistoryServiceKey.self] }
        set { self[AuthenticationHistoryServiceKey.self] = newValue }
    }
}
