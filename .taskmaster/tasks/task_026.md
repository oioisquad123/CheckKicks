# Task ID: 26

**Title:** Build settings screen with account and credit management

**Status:** done

**Dependencies:** 6, 17

**Priority:** medium

**Phase:** 1D - Monetization (implement AFTER Task 17 is complete)

**Description:** Create settings screen for account info, credit balance, purchase history, sign out (FR-8.5)

**Screen Sections:**
1. Credit Balance (prominent)
2. Purchase History
3. Account Info
4. Buy More Credits
5. About & Legal
6. Sign Out

**Details:**

**1. SettingsView Structure**

```swift
struct SettingsView: View {
    @Environment(CreditManager.self) private var creditManager
    @Environment(AuthenticationService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var showPurchaseScreen = false
    @State private var showSignOutConfirmation = false
    @State private var transactions: [CreditTransaction] = []

    var body: some View {
        NavigationStack {
            List {
                // Credit Balance Section
                creditBalanceSection

                // Purchase History Section
                purchaseHistorySection

                // Account Section
                accountSection

                // About Section
                aboutSection

                // Sign Out Section
                signOutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPurchaseScreen) {
                PurchaseView()
            }
            .task {
                await loadTransactionHistory()
            }
        }
    }
}
```

**2. Credit Balance Section (Prominent)**

```swift
var creditBalanceSection: some View {
    Section {
        VStack(spacing: 16) {
            // Large credit display
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Credits")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(creditManager.credits)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(AegisColors.gold)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(AegisColors.gold.opacity(0.3))
            }

            // Buy more button
            Button {
                showPurchaseScreen = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Buy More Credits")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AegisColors.gold)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}
```

**3. Purchase History Section**

```swift
var purchaseHistorySection: some View {
    Section("Purchase History") {
        if transactions.isEmpty {
            Text("No transactions yet")
                .foregroundStyle(.secondary)
        } else {
            ForEach(transactions.prefix(5)) { transaction in
                TransactionRow(transaction: transaction)
            }

            if transactions.count > 5 {
                NavigationLink("View All") {
                    TransactionHistoryView(transactions: transactions)
                }
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: CreditTransaction

    var body: some View {
        HStack {
            // Icon
            Image(systemName: transaction.creditsChange > 0 ? "plus.circle.fill" : "minus.circle.fill")
                .foregroundStyle(transaction.creditsChange > 0 ? .green : .red)

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(transactionTitle)
                    .font(.subheadline)
                Text(transaction.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Credits change
            Text("\(transaction.creditsChange > 0 ? "+" : "")\(transaction.creditsChange)")
                .font(.headline)
                .foregroundStyle(transaction.creditsChange > 0 ? .green : .red)
        }
    }

    var transactionTitle: String {
        switch transaction.transactionType {
        case "purchase": return "Credit Purchase"
        case "use": return "Authentication"
        case "bonus": return "Bonus Credits"
        case "refund": return "Refund"
        default: return "Transaction"
        }
    }
}
```

**4. Account Section**

```swift
var accountSection: some View {
    Section("Account") {
        // User email/Apple ID
        HStack {
            Label("Email", systemImage: "envelope")
            Spacer()
            Text(authService.currentUser?.email ?? "Apple ID")
                .foregroundStyle(.secondary)
        }

        // User ID (for support)
        HStack {
            Label("User ID", systemImage: "person.badge.key")
            Spacer()
            Text(authService.currentUser?.id.uuidString.prefix(8) ?? "")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }

        // Member since
        if let createdAt = authService.currentUser?.createdAt {
            HStack {
                Label("Member Since", systemImage: "calendar")
                Spacer()
                Text(createdAt, style: .date)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

**5. About Section**

```swift
var aboutSection: some View {
    Section("About") {
        // App version
        HStack {
            Label("Version", systemImage: "info.circle")
            Spacer()
            Text(Bundle.main.appVersion)
                .foregroundStyle(.secondary)
        }

        // Terms of Service
        Link(destination: URL(string: "https://yourapp.com/terms")!) {
            Label("Terms of Service", systemImage: "doc.text")
        }

        // Privacy Policy
        Link(destination: URL(string: "https://yourapp.com/privacy")!) {
            Label("Privacy Policy", systemImage: "hand.raised")
        }

        // Support
        Link(destination: URL(string: "mailto:support@yourapp.com")!) {
            Label("Contact Support", systemImage: "envelope")
        }
    }
}

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
```

**6. Sign Out Section**

```swift
var signOutSection: some View {
    Section {
        Button(role: .destructive) {
            showSignOutConfirmation = true
        } label: {
            HStack {
                Spacer()
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                Spacer()
            }
        }
    }
    .confirmationDialog(
        "Sign Out",
        isPresented: $showSignOutConfirmation,
        titleVisibility: .visible
    ) {
        Button("Sign Out", role: .destructive) {
            Task {
                try? await authService.signOut()
            }
        }
        Button("Cancel", role: .cancel) {}
    } message: {
        Text("Are you sure you want to sign out?")
    }
}
```

**7. Load Transaction History**

```swift
func loadTransactionHistory() async {
    do {
        transactions = try await creditManager.fetchTransactionHistory()
    } catch {
        // Handle error silently or show toast
    }
}
```

**8. Navigation to Settings**

```swift
// In HomeView toolbar
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape")
        }
    }
}
.sheet(isPresented: $showSettings) {
    SettingsView()
}
```

**Test Strategy:**

**UI Testing:**
- [x] Settings screen opens from Home
- [x] Credit balance displays correctly
- [x] Buy More Credits button opens purchase screen
- [x] Transaction history loads and displays
- [x] Account info shows correct data
- [x] Links open in browser/mail
- [x] Sign out shows confirmation
- [x] Sign out returns to auth screen

**Data Testing:**
- [x] Credits update after purchase (live refresh)
- [x] Transaction history updates after actions
- [x] User info matches authenticated user

**Completion Criteria:**
- [x] SettingsView created with all sections
- [x] Credit balance prominently displayed
- [x] Buy More Credits button works
- [x] Transaction history shows recent items
- [x] Account info displays correctly
- [x] Terms/Privacy links work
- [x] Sign out flow works
- [x] Accessible from Home screen

---

## Implementation Summary (January 11, 2026)

**Files Created:**
- `Views/Settings/SettingsView.swift` - Main settings view with Aegis Gold design
  - Credit Balance Section (large display + Buy More button)
  - Purchase History Section (with TransactionRow component)
  - Account Section (Email, User ID, Member Since)
  - About Section (Version, Terms, Privacy, Support links)
  - Sign Out Section (with confirmation dialog)
- `TransactionRow` - Reusable component for displaying transactions
- `SettingsInfoRow` - Reusable component for static info rows
- `SettingsLinkRow` - Reusable component for link rows
- `Bundle.appVersion` - Extension for version display

**Files Modified:**
- `Services/CreditManager.swift` - Added `fetchTransactionHistory()` method
- `Views/Home/HomeView.swift` - Added Settings menu option + sheet

**Design:**
- Custom Aegis Gold design (not SwiftUI List)
- Navy background with gold accents
- Matches PurchaseView aesthetic
