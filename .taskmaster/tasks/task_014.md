# Task ID: 14

**Title:** Integrate StoreKit 2 for Credit Pack Purchases (Consumables)

**Status:** done

**Dependencies:** 5, 13, 18, 19, 20, 23, 24

**Priority:** high

**Phase:** 1D - Monetization (implement AFTER core features are stable)

**Description:** Implement StoreKit 2 IAP with consumable credit packs for pay-per-use authentication (FR-6.1, FR-6.2)

**Monetization Strategy:** Credit-based system (NOT subscription)
- Users buy credit packs
- Each authentication costs 1 credit
- More credits = lower per-check price
- No recurring charges, no subscription fatigue

**Credit Tiers:**
| Tier | Credits | Price | Per Check |
|------|---------|-------|-----------|
| Free | 3 | $0 | Free (lifetime) |
| Basic | 10 | $6.99 | $0.70 |
| Standard | 25 | $14.99 | $0.60 |
| Pro | 60 | $29.99 | $0.50 |
| Business | 150 | $59.99 | $0.40 |

**Details:**

**1. Create StoreKit Configuration File (.storekit)**
- File > New > StoreKit Configuration File in Xcode
- Add products (Type: **Consumable**, NOT subscription):
  - Product ID: `com.checkkicks.credits.basic`
    - Reference Name: Basic Credits (10)
    - Price: $6.99 USD
  - Product ID: `com.checkkicks.credits.standard`
    - Reference Name: Standard Credits (25)
    - Price: $14.99 USD
  - Product ID: `com.checkkicks.credits.pro`
    - Reference Name: Pro Credits (60)
    - Price: $29.99 USD
  - Product ID: `com.checkkicks.credits.business`
    - Reference Name: Business Credits (150)
    - Price: $59.99 USD
- Enable in scheme: Edit Scheme > Run > StoreKit Configuration

**2. Implement CreditManager Service**
- Create Services/CreditManager.swift with @Observable
- Properties:
  - credits: Int = 0
  - isLoading: Bool = false
  - products: [Product] = []
- Methods:
  - loadProducts() async throws -> [Product]
  - purchase(_ product: Product) async throws -> Int (returns credits added)
  - useCredit() async throws -> Bool (deduct 1 credit)
  - syncCredits() async (sync with Supabase)
  - restorePurchases() async throws

**3. Product Loading**
```swift
let productIds = [
    "com.checkkicks.credits.basic",
    "com.checkkicks.credits.standard",
    "com.checkkicks.credits.pro",
    "com.checkkicks.credits.business"
]
let products = try await Product.products(for: productIds)
```

**4. Purchase Flow with Verification (Consumable)**
```swift
let result = try await product.purchase()
switch result {
case .success(let verification):
    switch verification {
    case .verified(let transaction):
        // Determine credits based on product ID
        let creditsToAdd = creditsForProduct(transaction.productID)
        // Add credits to user's balance
        credits += creditsToAdd
        // Sync to Supabase
        await syncCreditsToSupabase(creditsToAdd, transaction)
        // IMPORTANT: Finish transaction for consumables
        await transaction.finish()
        return creditsToAdd
    case .unverified:
        throw CreditError.verificationFailed
    }
case .userCancelled:
    throw CreditError.cancelled
case .pending:
    throw CreditError.pending
}
```

**5. Credits Mapping Function**
```swift
func creditsForProduct(_ productID: String) -> Int {
    switch productID {
    case "com.checkkicks.credits.basic": return 10
    case "com.checkkicks.credits.standard": return 25
    case "com.checkkicks.credits.pro": return 60
    case "com.checkkicks.credits.business": return 150
    default: return 0
    }
}
```

**6. Transaction Updates Listener**
```swift
Task {
    for await result in Transaction.updates {
        guard case .verified(let transaction) = result else {
            continue
        }
        // Handle any pending transactions
        if transaction.productType == .consumable {
            let credits = creditsForProduct(transaction.productID)
            await addCredits(credits, transaction)
        }
        await transaction.finish()
    }
}
```

**7. Credit Usage (Deduct on Authentication)**
```swift
func useCredit() async throws -> Bool {
    guard credits > 0 else {
        throw CreditError.insufficientCredits
    }
    credits -= 1
    await syncCreditsToSupabase(-1, nil)
    return true
}
```

**8. Restore Purchases (REQUIRED by Apple)**
```swift
// For consumables, restore shows transaction history
// but doesn't re-add credits (they're consumed)
try await AppStore.sync()
```

**9. Edge Cases to Handle**
- Insufficient credits (show purchase screen)
- Offline mode (cache credits locally, sync when online)
- Interrupted purchases (handle .pending state)
- Failed transactions (don't add credits)
- Concurrent purchases (thread-safe credit updates)

**10. Environment Integration**
- Add CreditManager to app environment
- Inject into views that need credit checks
- Check credits before each authentication

**Test Strategy:**

**Sandbox Testing Checklist:**
- [x] Create .storekit configuration file with 4 consumable products
- [x] Test purchase flow for each tier in simulator
- [x] Verify credits added correctly after purchase
- [x] Test using credits (deduction works)
- [x] Test insufficient credits shows purchase screen
- [x] Test credits persist across app restarts (local + Supabase)
- [x] Test with no internet (cached credits work)
- [x] Test multiple purchases accumulate credits
- [ ] Create sandbox Apple ID in App Store Connect
- [ ] Test on physical device with sandbox account

**Apple Review Requirements:**
- [x] "Restore Purchases" button easily accessible
- [x] Clear pricing shown for each tier
- [x] Credits balance displayed prominently
- [x] All StoreKit errors handled gracefully
- [x] No crashes on purchase failure

**Completion Criteria:**
- [x] CreditManager service created
- [x] All 4 credit pack products configured
- [x] Purchase flow works for all tiers
- [x] Credits correctly added after purchase
- [x] Credit deduction works on authentication
- [x] Credits synced to Supabase
- [x] Local caching for offline use
- [x] Tested in sandbox successfully

---

## Implementation Summary (January 11, 2026)

**Files Created/Modified:**
- `Auntentic_AI/Products.storekit` - StoreKit configuration with 4 consumable products
- `Auntentic_AI/Services/CreditManager.swift` - Full CreditManager implementation (508 lines)
- `Auntentic_AI/Services/CreditManagerKey.swift` - SwiftUI environment key
- `Auntentic_AI/Views/Purchase/PurchaseView.swift` - Purchase UI with Aegis Gold design
- `Auntentic_AI/Shared/Components/CreditBalanceView.swift` - Toolbar credit display
- `Auntentic_AI/App/Auntentic_AIApp.swift` - CreditManager environment integration
- `Auntentic_AI/Views/Home/HomeView.swift` - Credit check before analysis
- `Auntentic_AI/Views/PhotoCapture/PhotoReviewView.swift` - Credit deduction after auth

**Database Tables (Supabase):**
- `user_credits` - User credit balance tracking
- `credit_transactions` - Purchase and usage history
- `account_exceptions` - Developer/tester bypass

**Xcode Configuration:**
- StoreKit configuration linked in scheme (Auntentic_AI.xcscheme line 67)
