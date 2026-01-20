//
//  CreditManagerKey.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/10/26.
//  Task 14: Environment Key for CreditManager
//

import SwiftUI

// MARK: - Environment Key

private struct CreditManagerKey: EnvironmentKey {
    static let defaultValue = CreditManager()
}

extension EnvironmentValues {
    var creditManager: CreditManager {
        get { self[CreditManagerKey.self] }
        set { self[CreditManagerKey.self] = newValue }
    }
}
