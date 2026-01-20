//
//  KeychainHelper.swift
//  Auntentic_AI
//
//  Created by Claude AI on 1/11/26.
//  Phase 2: Secure storage wrapper for sensitive data
//

import Foundation
import Security

/// Secure Keychain wrapper for storing sensitive data like credit balances
enum KeychainHelper {

    // MARK: - Constants

    private static let service = "com.checkkicks.app"

    // MARK: - Errors

    enum KeychainError: Error {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
    }

    // MARK: - Core Methods

    /// Save data to Keychain
    static func save(_ data: Data, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        // Delete existing item first (upsert behavior)
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Read data from Keychain
    static func read(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    /// Delete data from Keychain
    static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Convenience Methods for Int

    /// Save an integer value to Keychain
    static func saveInt(_ value: Int, account: String) throws {
        let data = withUnsafeBytes(of: value) { Data($0) }
        try save(data, account: account)
    }

    /// Read an integer value from Keychain
    static func readInt(account: String) -> Int? {
        guard let data = read(account: account),
              data.count == MemoryLayout<Int>.size else { return nil }
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }

    // MARK: - Convenience Methods for Bool

    /// Save a boolean value to Keychain
    static func saveBool(_ value: Bool, account: String) throws {
        let data = Data([value ? 1 : 0])
        try save(data, account: account)
    }

    /// Read a boolean value from Keychain
    static func readBool(account: String) -> Bool? {
        guard let data = read(account: account),
              let byte = data.first else { return nil }
        return byte == 1
    }

    // MARK: - Migration Helper

    /// Migrate a value from UserDefaults to Keychain
    /// Returns true if migration occurred, false if no value existed
    @discardableResult
    static func migrateFromUserDefaults(key: String, account: String, type: ValueType) -> Bool {
        let defaults = UserDefaults.standard

        switch type {
        case .int:
            // Check if value exists (0 is a valid value, so we check object)
            guard defaults.object(forKey: key) != nil else { return false }
            let value = defaults.integer(forKey: key)
            try? saveInt(value, account: account)
            defaults.removeObject(forKey: key)
            return true

        case .bool:
            guard defaults.object(forKey: key) != nil else { return false }
            let value = defaults.bool(forKey: key)
            try? saveBool(value, account: account)
            defaults.removeObject(forKey: key)
            return true
        }
    }

    enum ValueType {
        case int
        case bool
    }
}
