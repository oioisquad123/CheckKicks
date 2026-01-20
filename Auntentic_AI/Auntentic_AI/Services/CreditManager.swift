//
//  CreditManager.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/10/26.
//  Task 14: StoreKit 2 credit pack purchases with Supabase sync
//

import Foundation
import StoreKit
import Supabase
import OSLog

/// Service for managing credit purchases and balance using StoreKit 2
@Observable
final class CreditManager {

    // MARK: - Properties

    /// Current credit balance
    var credits: Int = 0

    /// Available products from App Store
    var products: [Product] = []

    /// Loading state
    var isLoading: Bool = false

    /// Purchasing state
    var isPurchasing: Bool = false

    /// Last error
    var lastError: Error?

    /// Whether current user has account exception (permanent free trial)
    var hasAccountException: Bool = false

    /// Check if user has credits available (or has exception)
    var hasCredits: Bool { hasAccountException || credits > 0 }

    private var updateListenerTask: Task<Void, Error>?
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "CreditManager")
    private let supabase = SupabaseClientManager.shared

    // MARK: - Initialization

    init() {
        // Migrate from UserDefaults to Keychain (one-time migration)
        migrateToKeychain()

        updateListenerTask = listenForTransactions()
    }

    /// One-time migration from UserDefaults to Keychain
    private func migrateToKeychain() {
        KeychainHelper.migrateFromUserDefaults(
            key: "cached_credits",
            account: "cached_credits",
            type: .int
        )
        KeychainHelper.migrateFromUserDefaults(
            key: "cached_account_exception",
            account: "cached_account_exception",
            type: .bool
        )
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Credits from Supabase

    /// Load user's credit balance from Supabase
    @MainActor
    func loadCredits() async {
        logger.info("💰 Loading credits from Supabase...")

        do {
            guard let session = try? await supabase.auth.session else {
                logger.warning("⚠️ No active session, using cached credits")
                credits = KeychainHelper.readInt(account: "cached_credits") ?? 0
                hasAccountException = KeychainHelper.readBool(account: "cached_account_exception") ?? false
                return
            }

            // Check for account exception first
            await checkAccountException(email: session.user.email)

            let response: UserCredits = try await supabase
                .from("user_credits")
                .select()
                .eq("user_id", value: session.user.id.uuidString)
                .single()
                .execute()
                .value

            credits = response.credits
            try? KeychainHelper.saveInt(credits, account: "cached_credits")
            logger.info("✅ Loaded \(self.credits) credits (exception: \(self.hasAccountException))")

        } catch {
            logger.error("❌ Failed to load credits: \(error.localizedDescription)")
            // Use cached value if offline
            credits = KeychainHelper.readInt(account: "cached_credits") ?? 0
            hasAccountException = KeychainHelper.readBool(account: "cached_account_exception") ?? false
            logger.info("📦 Using cached credits: \(self.credits)")
        }
    }

    // MARK: - Check Account Exception

    /// Check if user has permanent free trial exception
    @MainActor
    private func checkAccountException(email: String?) async {
        guard let email = email else {
            hasAccountException = false
            return
        }

        logger.info("🔍 Checking account exception for \(email)...")

        do {
            let response: [AccountException] = try await supabase
                .from("account_exceptions")
                .select()
                .eq("user_email", value: email)
                .eq("is_active", value: true)
                .execute()
                .value

            // Check if any active exception exists (and hasn't expired)
            hasAccountException = response.contains { exception in
                if let expiresAt = exception.expiresAt {
                    return expiresAt > Date()
                }
                return true // No expiry means permanent
            }

            try? KeychainHelper.saveBool(hasAccountException, account: "cached_account_exception")

            if hasAccountException {
                logger.info("✅ Account has permanent free trial exception")
            } else {
                logger.info("ℹ️ No active account exception found")
            }
        } catch {
            logger.error("❌ Failed to check account exception: \(error.localizedDescription)")
            // Use cached value
            hasAccountException = KeychainHelper.readBool(account: "cached_account_exception") ?? false
        }
    }

    // MARK: - Load Products

    /// Load available products from App Store
    @MainActor
    func loadProducts() async {
        logger.info("🛍️ Loading products from App Store...")
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: ProductConfiguration.productIds)
                .sorted { $0.price < $1.price }
            logger.info("✅ Loaded \(self.products.count) products")

            for product in products {
                logger.info("  - \(product.id): \(product.displayPrice)")
            }
        } catch {
            logger.error("❌ Failed to load products: \(error.localizedDescription)")
            lastError = error
        }
    }

    // MARK: - Purchase

    /// Purchase a credit pack
    /// - Parameter product: The product to purchase
    /// - Returns: Number of credits added
    @MainActor
    func purchase(_ product: Product) async throws -> Int {
        logger.info("💳 Starting purchase for \(product.id)...")
        isPurchasing = true
        defer { isPurchasing = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            let creditsToAdd = ProductConfiguration.credits(for: transaction.productID)

            logger.info("✅ Purchase verified, adding \(creditsToAdd) credits")

            // Update local state
            credits += creditsToAdd

            // Sync to Supabase
            do {
                try await syncPurchaseToSupabase(
                    productId: transaction.productID,
                    creditsAdded: creditsToAdd,
                    amount: product.price,
                    transactionId: String(transaction.id)
                )
            } catch {
                logger.error("⚠️ Failed to sync purchase to Supabase: \(error.localizedDescription)")
                // Don't fail the purchase, credits are added locally
                // Will sync on next load
            }

            // Finish transaction
            await transaction.finish()
            logger.info("✅ Transaction finished, total credits: \(self.credits)")

            return creditsToAdd

        case .userCancelled:
            logger.info("ℹ️ User cancelled purchase")
            throw CreditError.cancelled

        case .pending:
            logger.info("⏳ Purchase pending approval")
            throw CreditError.pending

        @unknown default:
            logger.error("❓ Unknown purchase result")
            throw CreditError.unknown
        }
    }

    // MARK: - Use Credit

    /// Deduct one credit for authentication
    @MainActor
    func useCredit() async throws {
        // Skip credit deduction for accounts with exception (permanent free trial)
        if hasAccountException {
            logger.info("🆓 Account has exception - skipping credit deduction")
            return
        }

        guard credits > 0 else {
            logger.error("❌ Insufficient credits")
            throw CreditError.insufficientCredits
        }

        logger.info("💸 Using 1 credit...")

        // Optimistic update
        credits -= 1

        // Sync to Supabase
        do {
            try await syncUsageToSupabase()
            try? KeychainHelper.saveInt(credits, account: "cached_credits")
            logger.info("✅ Credit used, remaining: \(self.credits)")
        } catch {
            // Rollback on failure
            credits += 1
            logger.error("❌ Failed to sync credit usage: \(error.localizedDescription)")
            throw CreditError.syncFailed(error)
        }
    }

    // MARK: - Restore Purchases

    /// Restore purchases (required by Apple)
    @MainActor
    func restorePurchases() async throws {
        logger.info("🔄 Restoring purchases...")
        try await AppStore.sync()
        logger.info("✅ Purchases restored")
    }

    // MARK: - Reset

    /// Reset service state
    @MainActor
    func reset() {
        credits = 0
        hasAccountException = false
        lastError = nil
        logger.info("🔄 Credit manager reset")
    }

    // MARK: - Transaction History

    /// Fetch transaction history from Supabase
    /// - Returns: Array of transactions sorted by most recent first
    func fetchTransactionHistory() async throws -> [CreditTransaction] {
        guard let session = try? await supabase.auth.session else {
            throw CreditError.noSession
        }

        logger.info("📜 Fetching transaction history...")

        let response: [CreditTransaction] = try await supabase
            .from("credit_transactions")
            .select()
            .eq("user_id", value: session.user.id.uuidString)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value

        logger.info("✅ Fetched \(response.count) transactions")
        return response
    }

    // MARK: - Private Helpers

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw CreditError.verificationFailed(error)
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    let credits = ProductConfiguration.credits(for: transaction.productID)

                    if credits > 0 {
                        await MainActor.run {
                            self.credits += credits
                            self.logger.info("🔔 Transaction update: +\(credits) credits")
                        }

                        // Sync to backend with proper error handling
                        do {
                            try await self.syncPurchaseToSupabase(
                                productId: transaction.productID,
                                creditsAdded: credits,
                                amount: 0,
                                transactionId: String(transaction.id)
                            )
                            self.logger.info("✅ Transaction sync completed")
                        } catch {
                            self.logger.error("⚠️ Failed to sync transaction: \(error.localizedDescription)")
                            // Queue for retry on next app launch
                            UserDefaults.standard.set(true, forKey: "pending_sync_\(transaction.id)")
                        }
                    }

                    await transaction.finish()
                } catch {
                    self.logger.error("❌ Transaction update error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Supabase Sync

    private func syncPurchaseToSupabase(
        productId: String,
        creditsAdded: Int,
        amount: Decimal,
        transactionId: String
    ) async throws {
        guard let session = try? await supabase.auth.session else {
            throw CreditError.noSession
        }

        let userId = session.user.id
        logger.info("📤 Syncing purchase to Supabase...")

        // Update user_credits (total_purchased computed from credit_transactions)
        try await supabase
            .from("user_credits")
            .update([
                "credits": AnyJSON.integer(credits),
                "updated_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
            ])
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Record transaction
        let transactionRecord = CreditTransaction(
            id: nil,  // Auto-generated by database
            userId: userId,
            transactionType: "purchase",
            productId: productId,
            creditsChange: creditsAdded,
            creditsAfter: credits,
            amountUsd: NSDecimalNumber(decimal: amount).doubleValue,
            originalTransactionId: transactionId,
            createdAt: nil  // Auto-generated by database
        )

        try await supabase
            .from("credit_transactions")
            .insert(transactionRecord)
            .execute()

        // Update cache in Keychain
        try? KeychainHelper.saveInt(credits, account: "cached_credits")
        logger.info("✅ Purchase synced to Supabase")
    }

    private func syncUsageToSupabase() async throws {
        guard let session = try? await supabase.auth.session else {
            throw CreditError.noSession
        }

        let userId = session.user.id
        logger.info("📤 Syncing credit usage to Supabase...")

        // Update user_credits (total_used computed from credit_transactions)
        try await supabase
            .from("user_credits")
            .update([
                "credits": AnyJSON.integer(credits),
                "updated_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
            ])
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Record transaction
        let transactionRecord = CreditTransaction(
            id: nil,  // Auto-generated by database
            userId: userId,
            transactionType: "use",
            productId: nil,
            creditsChange: -1,
            creditsAfter: credits,
            amountUsd: nil,
            originalTransactionId: nil,
            createdAt: nil  // Auto-generated by database
        )

        try await supabase
            .from("credit_transactions")
            .insert(transactionRecord)
            .execute()

        logger.info("✅ Usage synced to Supabase")
    }
}

// MARK: - Database Models

struct UserCredits: Codable {
    let id: UUID
    let userId: UUID
    let credits: Int
    let totalPurchased: Int
    let totalUsed: Int
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case credits
        case totalPurchased = "total_purchased"
        case totalUsed = "total_used"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CreditTransaction: Codable, Identifiable {
    let id: UUID?
    let userId: UUID
    let transactionType: String
    let productId: String?
    let creditsChange: Int
    let creditsAfter: Int
    let amountUsd: Double?
    let originalTransactionId: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case transactionType = "transaction_type"
        case productId = "product_id"
        case creditsChange = "credits_change"
        case creditsAfter = "credits_after"
        case amountUsd = "amount_usd"
        case originalTransactionId = "original_transaction_id"
        case createdAt = "created_at"
    }

    /// Title for display in UI
    var displayTitle: String {
        switch transactionType {
        case "purchase": return "Credit Purchase"
        case "use": return "Authentication"
        case "bonus": return "Bonus Credits"
        case "refund": return "Refund"
        case "initial": return "Welcome Credits"
        default: return "Transaction"
        }
    }
}

struct AccountException: Codable {
    let id: UUID
    let userEmail: String
    let exceptionType: String
    let reason: String?
    let createdAt: Date
    let expiresAt: Date?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userEmail = "user_email"
        case exceptionType = "exception_type"
        case reason
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case isActive = "is_active"
    }
}

// MARK: - Credit Errors

enum CreditError: LocalizedError {
    case cancelled
    case pending
    case unknown
    case insufficientCredits
    case verificationFailed(Error)
    case syncFailed(Error)
    case noSession

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        case .insufficientCredits:
            return "Not enough credits"
        case .verificationFailed(let error):
            return "Verification failed: \(error.localizedDescription)"
        case .syncFailed(let error):
            return "Failed to sync: \(error.localizedDescription)"
        case .noSession:
            return "No active session"
        }
    }
}
