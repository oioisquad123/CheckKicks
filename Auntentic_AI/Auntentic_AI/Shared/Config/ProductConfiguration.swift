//
//  ProductConfiguration.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/11/26.
//  Phase 3: Centralized configuration for StoreKit products
//

import Foundation

/// Centralized configuration for StoreKit credit pack products
/// This eliminates duplicate product ID definitions across CreditManager and PurchaseView
enum ProductConfiguration {

    // MARK: - Product IDs

    /// All available credit pack product IDs
    static let productIds = [
        "com.checkkicks.credits.basic",      // 10 credits - $6.99
        "com.checkkicks.credits.standard",   // 25 credits - $14.99
        "com.checkkicks.credits.pro",        // 60 credits - $29.99
        "com.checkkicks.credits.business"    // 150 credits - $59.99
    ]

    // MARK: - Credit Mapping

    /// Credit amounts per product
    static let creditMapping: [String: Int] = [
        "com.checkkicks.credits.basic": 10,
        "com.checkkicks.credits.standard": 25,
        "com.checkkicks.credits.pro": 60,
        "com.checkkicks.credits.business": 150
    ]

    // MARK: - Popular Products

    /// Products marked as "POPULAR" in the UI
    static let popularProducts: Set<String> = [
        "com.checkkicks.credits.standard"
    ]

    // MARK: - Helper Methods

    /// Check if a product is marked as popular
    /// - Parameter productId: The product identifier to check
    /// - Returns: True if the product is in the popular set
    static func isPopular(_ productId: String) -> Bool {
        popularProducts.contains(productId)
    }

    /// Get the credit amount for a product ID
    /// - Parameter productId: The product identifier
    /// - Returns: Number of credits for the product, or 0 if not found
    static func credits(for productId: String) -> Int {
        creditMapping[productId] ?? 0
    }
}
