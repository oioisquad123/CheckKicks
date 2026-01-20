//
//  AuthenticationServiceKey.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Task 6: Environment Key for Authentication Service
//

import SwiftUI

// MARK: - Environment Key

private struct AuthenticationServiceKey: EnvironmentKey {
    static let defaultValue = AuthenticationService()
}

extension EnvironmentValues {
    var authenticationService: AuthenticationService {
        get { self[AuthenticationServiceKey.self] }
        set { self[AuthenticationServiceKey.self] = newValue }
    }
}
