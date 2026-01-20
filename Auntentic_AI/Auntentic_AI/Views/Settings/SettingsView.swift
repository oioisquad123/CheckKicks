//
//  SettingsView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/11/26.
//  Task 26: Settings screen with account and credit management
//

import SwiftUI
import Auth

/// Settings screen with Aegis Gold design
struct SettingsView: View {
    @Environment(\.creditManager) private var creditManager
    @Environment(\.authenticationService) private var authService
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.appReviewManager) private var appReviewManager
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var showPurchaseSheet = false
    @State private var showSignOutConfirmation = false
    @State private var showSignOutError = false
    @State private var signOutErrorMessage = ""
    @State private var transactions: [CreditTransaction] = []
    @State private var isLoadingTransactions = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Credit Balance Section
                    creditBalanceSection

                    // Purchase History Section
                    purchaseHistorySection

                    // Account Section
                    accountSection

                    // Feedback Section
                    feedbackSection

                    // About Section
                    aboutSection

                    // Sign Out Section
                    signOutSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .withAegisBackground(showWatermark: false)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.aegisGoldMid)
                }
            }
        }
        .sheet(isPresented: $showPurchaseSheet) {
            PurchaseView()
        }
        .confirmationDialog(
            "Sign Out",
            isPresented: $showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                handleSignOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .task {
            await loadTransactionHistory()
        }
        .alert("Sign Out Failed", isPresented: $showSignOutError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(signOutErrorMessage)
        }
    }

    // MARK: - Credit Balance Section

    private var creditBalanceSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Credits")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGray)

                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.aegisGoldMid)

                        Text("\(creditManager.credits)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(Color.aegisWhite)
                    }
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.aegisGoldMid.opacity(0.3))
            }

            // Buy More Credits button
            Button {
                HapticManager.mediumImpact()
                showPurchaseSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Buy More Credits")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(LinearGradient.aegisGoldGradient)
                .foregroundStyle(Color.aegisInk)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.aegisNavyElevated)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.aegisGoldMid.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Purchase History Section

    private var purchaseHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            AegisSectionHeader(title: "Purchase History")

            VStack(spacing: 0) {
                if isLoadingTransactions {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color.aegisGoldMid)
                        Spacer()
                    }
                    .padding(.vertical, 20)
                } else if transactions.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.aegisGray)
                            Text("No transactions yet")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.aegisGray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                } else {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)

                        if index < min(4, transactions.count - 1) {
                            Divider()
                                .background(Color.aegisGray.opacity(0.2))
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            AegisSectionHeader(title: "Account")

            VStack(spacing: 0) {
                // Email
                SettingsInfoRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: authService.currentUser?.email ?? "Apple ID"
                )

                Divider()
                    .background(Color.aegisGray.opacity(0.2))

                // User ID
                SettingsInfoRow(
                    icon: "person.badge.key.fill",
                    title: "User ID",
                    value: String(authService.currentUser?.id.uuidString.prefix(8) ?? "")
                )

                Divider()
                    .background(Color.aegisGray.opacity(0.2))

                // Member Since
                SettingsInfoRow(
                    icon: "calendar",
                    title: "Member Since",
                    value: formattedMemberDate
                )
            }
            .padding(16)
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Feedback Section

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            AegisSectionHeader(title: "Feedback")

            VStack(spacing: 0) {
                // Rate App
                SettingsActionRow(
                    icon: "star.fill",
                    title: "Rate Auntentic"
                ) {
                    HapticManager.lightImpact()
                    appReviewManager.requestReview()
                }

                Divider()
                    .background(Color.aegisGray.opacity(0.2))

                // Send Feedback (email)
                if let feedbackURL = appReviewManager.feedbackEmailURL() {
                    SettingsLinkRow(
                        icon: "envelope.fill",
                        title: "Send Feedback",
                        url: feedbackURL
                    )
                }

                // TestFlight-only option
                if appReviewManager.isTestFlight {
                    Divider()
                        .background(Color.aegisGray.opacity(0.2))

                    SettingsActionRow(
                        icon: "paperplane.fill",
                        title: "TestFlight Beta Feedback"
                    ) {
                        // Open TestFlight feedback via screenshot or shake gesture info
                        if let url = URL(string: "https://beta.apple.com/sp/betaprogram/") {
                            openURL(url)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            AegisSectionHeader(title: "About")

            VStack(spacing: 0) {
                // Version
                SettingsInfoRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    value: Bundle.main.appVersion
                )

                Divider()
                    .background(Color.aegisGray.opacity(0.2))

                // Terms of Service
                SettingsLinkRow(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    url: URL(string: "https://checkkicks.app/terms")!
                )

                Divider()
                    .background(Color.aegisGray.opacity(0.2))

                // Privacy Policy
                SettingsLinkRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    url: URL(string: "https://checkkicks.app/privacy")!
                )

                Divider()
                    .background(Color.aegisGray.opacity(0.2))

                // Contact Support
                SettingsLinkRow(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    url: URL(string: "mailto:support@checkkicks.app")!
                )
            }
            .padding(16)
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Sign Out Section

    private var signOutSection: some View {
        Button {
            HapticManager.mediumImpact()
            showSignOutConfirmation = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Sign Out")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(Color.aegisError)
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.aegisError.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var formattedMemberDate: String {
        guard let createdAt = authService.currentUser?.createdAt else {
            return "Unknown"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }

    private func loadTransactionHistory() async {
        isLoadingTransactions = true
        defer { isLoadingTransactions = false }

        do {
            transactions = try await creditManager.fetchTransactionHistory()
        } catch {
            // Silently fail - empty state will be shown
            transactions = []
        }
    }

    private func handleSignOut() {
        Task {
            do {
                try await authService.signOut()
                await MainActor.run {
                    dismiss()
                    coordinator.popToRoot()
                    coordinator.navigateToAuth()
                }
            } catch {
                await MainActor.run {
                    signOutErrorMessage = "Unable to sign out. Please try again."
                    showSignOutError = true
                }
            }
        }
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: CreditTransaction

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: transaction.creditsChange > 0 ? "plus.circle.fill" : "minus.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(transaction.creditsChange > 0 ? Color.aegisSuccess : Color.aegisError)

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.displayTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.aegisWhite)

                if let createdAt = transaction.createdAt {
                    Text(createdAt, style: .date)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.aegisGray)
                }
            }

            Spacer()

            // Credits change
            Text("\(transaction.creditsChange > 0 ? "+" : "")\(transaction.creditsChange)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(transaction.creditsChange > 0 ? Color.aegisSuccess : Color.aegisError)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Settings Info Row

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.aegisGoldMid)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.aegisWhite)

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(Color.aegisGray)
                .lineLimit(1)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Settings Link Row

struct SettingsLinkRow: View {
    let icon: String
    let title: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.aegisGoldMid)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.aegisWhite)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.aegisGray)
            }
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Settings Action Row

struct SettingsActionRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.aegisGoldMid)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.aegisWhite)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.aegisGray)
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environment(\.creditManager, CreditManager())
        .environment(\.authenticationService, AuthenticationService())
        .environment(\.navigationCoordinator, NavigationCoordinator())
        .environment(\.appReviewManager, AppReviewManager())
}
