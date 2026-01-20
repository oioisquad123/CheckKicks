//
//  AsyncTimeout.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Utility for adding timeout to async operations
//

import Foundation

/// Errors thrown by timeout operations
enum TimeoutError: LocalizedError {
    case timedOut

    var errorDescription: String? {
        switch self {
        case .timedOut:
            return "Operation timed out"
        }
    }
}

/// Execute an async operation with a timeout
/// - Parameters:
///   - seconds: Maximum time to wait in seconds
///   - operation: The async operation to execute
/// - Returns: The result of the operation
/// - Throws: TimeoutError.timedOut if the operation exceeds the timeout, or the operation's error
func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        // Add the actual operation
        group.addTask {
            try await operation()
        }

        // Add the timeout task
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError.timedOut
        }

        // Wait for the first task to complete
        let result = try await group.next()!

        // Cancel remaining tasks
        group.cancelAll()

        return result
    }
}
