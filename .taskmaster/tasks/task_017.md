# Task ID: 17

**Title:** Sync credit balance and transactions to Supabase

**Status:** pending

**Dependencies:** 3, 16

**Priority:** medium

**Phase:** 1D - Monetization (implement AFTER Task 16 is complete)

**Description:** Sync credit purchases and usage to Supabase for persistence and analytics (FR-6.7, FR-6.9)

**Purpose:**
- Persist credits across devices
- Track purchase history
- Analytics on revenue
- Backup for credit balance

**Details:**

**1. Database Schema**

Create `credit_transactions` table:
```sql
CREATE TABLE credit_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'use', 'bonus', 'refund')),
    product_id TEXT,
    credits_change INTEGER NOT NULL,
    credits_after INTEGER NOT NULL,
    amount_usd DECIMAL(10,2),
    original_transaction_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for user queries
CREATE INDEX idx_credit_transactions_user ON credit_transactions(user_id, created_at DESC);

-- RLS Policies
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own transactions"
ON credit_transactions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions"
ON credit_transactions FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

**2. Sync Credits After Purchase**

```swift
// In CreditManager.swift
func syncPurchaseToSupabase(
    productId: String,
    creditsAdded: Int,
    amountUSD: Decimal,
    transactionId: String
) async throws {
    // 1. Update user_credits table
    try await supabase
        .from("user_credits")
        .update([
            "credits": credits,
            "total_purchased": \.total_purchased + creditsAdded,
            "updated_at": Date()
        ])
        .eq("user_id", currentUserId)
        .execute()

    // 2. Record transaction
    try await supabase
        .from("credit_transactions")
        .insert([
            "user_id": currentUserId,
            "transaction_type": "purchase",
            "product_id": productId,
            "credits_change": creditsAdded,
            "credits_after": credits,
            "amount_usd": amountUSD,
            "original_transaction_id": transactionId
        ])
        .execute()
}
```

**3. Sync Credits After Usage**

```swift
func syncUsageToSupabase(authenticationId: UUID) async throws {
    // 1. Update user_credits table
    try await supabase
        .from("user_credits")
        .update([
            "credits": credits,
            "total_used": \.total_used + 1,
            "updated_at": Date()
        ])
        .eq("user_id", currentUserId)
        .execute()

    // 2. Record transaction
    try await supabase
        .from("credit_transactions")
        .insert([
            "user_id": currentUserId,
            "transaction_type": "use",
            "credits_change": -1,
            "credits_after": credits
        ])
        .execute()
}
```

**4. Fetch Credit History**

```swift
func fetchTransactionHistory() async throws -> [CreditTransaction] {
    let response = try await supabase
        .from("credit_transactions")
        .select()
        .eq("user_id", currentUserId)
        .order("created_at", ascending: false)
        .limit(50)
        .execute()

    return try JSONDecoder().decode([CreditTransaction].self, from: response.data)
}

struct CreditTransaction: Codable, Identifiable {
    let id: UUID
    let transactionType: String
    let productId: String?
    let creditsChange: Int
    let creditsAfter: Int
    let amountUsd: Decimal?
    let createdAt: Date
}
```

**5. Sync on App Launch**

```swift
func syncCreditsOnLaunch() async {
    do {
        // Fetch latest balance from server
        let response = try await supabase
            .from("user_credits")
            .select()
            .eq("user_id", currentUserId)
            .single()
            .execute()

        let serverCredits = try JSONDecoder().decode(UserCredits.self, from: response.data)

        // Server is source of truth
        self.credits = serverCredits.credits

        // Update local cache
        UserDefaults.standard.set(credits, forKey: "cached_credits")
    } catch {
        // Use cached value if offline
        self.credits = UserDefaults.standard.integer(forKey: "cached_credits")
    }
}
```

**6. Handle Offline Purchases**

```swift
// Queue for offline sync
@AppStorage("pending_sync") private var pendingSyncData: Data?

func queueForSync(_ transaction: PendingTransaction) {
    var pending = decodePending() ?? []
    pending.append(transaction)
    pendingSyncData = try? JSONEncoder().encode(pending)
}

func processPendingSync() async {
    guard let pending = decodePending(), !pending.isEmpty else { return }

    for transaction in pending {
        do {
            try await syncToSupabase(transaction)
        } catch {
            // Keep in queue for retry
            continue
        }
    }

    // Clear synced items
    pendingSyncData = nil
}
```

**Test Strategy:**

**Sync Testing:**
- [ ] Purchase syncs to user_credits table
- [ ] Purchase creates credit_transactions record
- [ ] Usage syncs to user_credits table
- [ ] Usage creates credit_transactions record
- [ ] Transaction history fetches correctly
- [ ] Credits sync on app launch
- [ ] Offline purchases queue and sync later
- [ ] Multiple devices show same balance

**Data Integrity:**
- [ ] credits_after matches actual balance
- [ ] total_purchased accumulates correctly
- [ ] total_used accumulates correctly
- [ ] No duplicate transactions

**Completion Criteria:**
- [ ] credit_transactions table created
- [ ] Purchase sync implemented
- [ ] Usage sync implemented
- [ ] Transaction history query works
- [ ] App launch sync works
- [ ] Offline queue and retry works
- [ ] All test cases pass
