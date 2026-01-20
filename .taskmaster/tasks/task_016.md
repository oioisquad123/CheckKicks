# Task ID: 16

**Title:** Build credit purchase screen with tier selection

**Status:** pending

**Dependencies:** 14, 15

**Priority:** high

**Phase:** 1D - Monetization (implement AFTER Task 15 is complete)

**Description:** Conversion-focused purchase screen showing credit tiers with clear value proposition (FR-6.4, FR-6.5, FR-6.8)

**Screen Purpose:**
- Show when user has 0 credits
- Display all credit tier options
- Highlight best value (Standard tier)
- Easy purchase flow

**Credit Tiers to Display:**
| Tier | Credits | Price | Per Check | Badge |
|------|---------|-------|-----------|-------|
| Basic | 10 | $6.99 | $0.70 | - |
| Standard | 25 | $14.99 | $0.60 | Best Value |
| Pro | 60 | $29.99 | $0.50 | Popular |
| Business | 150 | $59.99 | $0.40 | Save 43% |

**Details:**

**1. PurchaseView Structure**

```swift
struct PurchaseView: View {
    @Environment(CreditManager.self) private var creditManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Current balance
                    currentBalanceSection

                    // Credit tier cards
                    creditTiersSection

                    // Restore purchases
                    restorePurchasesButton

                    // Terms & Privacy
                    legalSection
                }
                .padding()
            }
            .background(AegisColors.background)
            .navigationTitle("Get Credits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
```

**2. Header Section**

```swift
var headerSection: some View {
    VStack(spacing: 12) {
        Image(systemName: "checkmark.seal.fill")
            .font(.system(size: 60))
            .foregroundStyle(AegisColors.gold)

        Text("Authenticate More Sneakers")
            .font(.title2.bold())

        Text("Buy credits to verify your collection. More credits = bigger savings.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}
```

**3. Current Balance Display**

```swift
var currentBalanceSection: some View {
    HStack {
        Text("Current Balance:")
            .foregroundStyle(.secondary)
        Spacer()
        Text("\(creditManager.credits) credits")
            .font(.headline)
            .foregroundStyle(creditManager.credits > 0 ? AegisColors.gold : .red)
    }
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
}
```

**4. Credit Tier Cards**

```swift
var creditTiersSection: some View {
    VStack(spacing: 16) {
        ForEach(creditManager.products.sorted(by: { $0.price < $1.price })) { product in
            CreditTierCard(
                product: product,
                isSelected: selectedProduct?.id == product.id,
                onSelect: { selectedProduct = product },
                onPurchase: { purchaseProduct(product) }
            )
        }
    }
}

struct CreditTierCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    let onPurchase: () -> Void

    var credits: Int {
        switch product.id {
        case "com.checkkicks.credits.basic": return 10
        case "com.checkkicks.credits.standard": return 25
        case "com.checkkicks.credits.pro": return 60
        case "com.checkkicks.credits.business": return 150
        default: return 0
        }
    }

    var perCheckPrice: String {
        let price = product.price / Decimal(credits)
        return price.formatted(.currency(code: "USD"))
    }

    var badge: String? {
        switch product.id {
        case "com.checkkicks.credits.standard": return "Best Value"
        case "com.checkkicks.credits.pro": return "Popular"
        case "com.checkkicks.credits.business": return "Save 43%"
        default: return nil
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Badge
            if let badge = badge {
                Text(badge)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(AegisColors.gold)
                    .clipShape(Capsule())
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(credits) Credits")
                        .font(.headline)
                    Text("\(perCheckPrice) per check")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onPurchase) {
                    Text(product.displayPrice)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AegisColors.gold)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(badge != nil ? AegisColors.gold : .clear, lineWidth: 2)
        )
    }
}
```

**5. Purchase Function**

```swift
func purchaseProduct(_ product: Product) {
    Task {
        isPurchasing = true
        do {
            let credits = try await creditManager.purchase(product)
            // Success - dismiss or show confirmation
            dismiss()
        } catch CreditError.cancelled {
            // User cancelled - do nothing
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isPurchasing = false
    }
}
```

**6. Restore Purchases Button**

```swift
var restorePurchasesButton: some View {
    Button("Restore Purchases") {
        Task {
            try? await creditManager.restorePurchases()
        }
    }
    .font(.subheadline)
    .foregroundStyle(.secondary)
}
```

**7. Legal Section**

```swift
var legalSection: some View {
    VStack(spacing: 8) {
        Text("By purchasing, you agree to our")
            .font(.caption)
            .foregroundStyle(.secondary)

        HStack(spacing: 16) {
            Link("Terms of Service", destination: URL(string: "https://yourapp.com/terms")!)
            Link("Privacy Policy", destination: URL(string: "https://yourapp.com/privacy")!)
        }
        .font(.caption)
    }
}
```

**8. Show Purchase Screen Trigger**

```swift
// In HomeView or PhotoReviewView
.sheet(isPresented: $showPurchaseScreen) {
    PurchaseView()
        .environment(creditManager)
}

// Trigger when credits = 0
if creditManager.credits == 0 {
    showPurchaseScreen = true
}
```

**Test Strategy:**

**UI Testing:**
- [ ] Purchase screen displays correctly
- [ ] All 4 credit tiers shown with correct prices
- [ ] "Best Value" badge on Standard tier
- [ ] Per-check price calculated correctly
- [ ] Current balance displays
- [ ] Purchase button triggers StoreKit flow
- [ ] Loading state during purchase
- [ ] Success dismisses screen
- [ ] Error shows alert
- [ ] Restore purchases button works
- [ ] Terms/Privacy links work

**Integration Testing:**
- [ ] Screen appears when credits = 0
- [ ] Can dismiss without purchasing
- [ ] Credits update after purchase
- [ ] Can purchase multiple times

**Completion Criteria:**
- [ ] PurchaseView created with Aegis Gold theme
- [ ] All 4 credit tier cards displayed
- [ ] Pricing and per-check calculations correct
- [ ] Purchase flow integrated with CreditManager
- [ ] Restore purchases functional
- [ ] Error handling with user feedback
- [ ] Triggers correctly when credits = 0
