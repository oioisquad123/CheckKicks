//
//  PurchaseView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/10/26.
//  Task 14: Credit pack purchase UI with Aegis design
//

import SwiftUI
import StoreKit

/// Credit pack purchase screen with Aegis Gold design
struct PurchaseView: View {
    @Environment(\.creditManager) private var creditManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var purchasedCredits = 0

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Current Balance
                    balanceCard

                    // Credit Packs
                    creditPacksSection

                    // Restore Purchases
                    restoreButton

                    // Terms
                    termsText
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .withAegisBackground(showWatermark: false)
            .navigationTitle("Get Credits")
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
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Purchase Complete!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Added \(purchasedCredits) credits to your account.")
        }
        .task {
            if creditManager.products.isEmpty {
                await creditManager.loadProducts()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(LinearGradient.aegisGoldGradient)

            Text("Purchase Credits")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.aegisWhite)

            Text("Credits are used for sneaker authentications")
                .font(.system(size: 14))
                .foregroundStyle(Color.aegisGray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Balance")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.aegisGray)

                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.aegisGoldMid)

                    Text("\(creditManager.credits)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)

                    Text("credits")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                }
            }

            Spacer()

            Image(systemName: "creditcard.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.aegisGoldMid.opacity(0.3))
        }
        .padding(16)
        .background(Color.aegisNavyElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Credit Packs Section

    private var creditPacksSection: some View {
        VStack(spacing: 12) {
            if creditManager.isLoading {
                ProgressView()
                    .tint(Color.aegisGoldMid)
                    .padding(40)
            } else if creditManager.products.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.aegisWarning)
                    Text("Unable to load products")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.aegisGray)
                    Button("Retry") {
                        Task { await creditManager.loadProducts() }
                    }
                    .foregroundStyle(Color.aegisGoldMid)
                }
                .padding(40)
            } else {
                ForEach(creditManager.products, id: \.id) { product in
                    CreditPackCard(
                        product: product,
                        credits: ProductConfiguration.credits(for: product.id),
                        isPopular: ProductConfiguration.isPopular(product.id),
                        isPurchasing: isPurchasing && selectedProduct?.id == product.id
                    ) {
                        await purchaseProduct(product)
                    }
                }
            }
        }
    }

    // MARK: - Restore Button

    private var restoreButton: some View {
        Button {
            Task {
                do {
                    try await creditManager.restorePurchases()
                } catch {
                    errorMessage = "Failed to restore purchases"
                    showError = true
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.aegisGray)
        }
        .padding(.top, 8)
    }

    // MARK: - Terms Text

    private var termsText: some View {
        Text("Credits are consumable and non-refundable. Each authentication uses 1 credit.")
            .font(.system(size: 11))
            .foregroundStyle(Color.aegisMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
    }

    // MARK: - Purchase Logic

    private func purchaseProduct(_ product: Product) async {
        selectedProduct = product
        isPurchasing = true

        do {
            let credits = try await creditManager.purchase(product)
            purchasedCredits = credits
            showSuccess = true
        } catch CreditError.cancelled {
            // User cancelled, do nothing
        } catch CreditError.pending {
            errorMessage = "Your purchase is pending approval."
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isPurchasing = false
        selectedProduct = nil
    }
}

// MARK: - Credit Pack Card

struct CreditPackCard: View {
    let product: Product
    let credits: Int
    let isPopular: Bool
    let isPurchasing: Bool
    let onPurchase: () async -> Void

    private var perCreditPrice: String {
        let price = (product.price as NSDecimalNumber).doubleValue
        let perCredit = price / Double(credits)
        return String(format: "$%.2f", perCredit)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Credits info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("\(credits)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)

                    Text("Credits")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGray)

                    if isPopular {
                        Text("POPULAR")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.aegisInk)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.aegisGoldMid)
                            .clipShape(Capsule())
                    }
                }

                Text("\(perCreditPrice) per check")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.aegisMuted)
            }

            Spacer()

            // Purchase button
            Button {
                Task { await onPurchase() }
            } label: {
                Group {
                    if isPurchasing {
                        ProgressView()
                            .tint(Color.aegisInk)
                    } else {
                        Text(product.displayPrice)
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .frame(width: 80, height: 36)
                .background(LinearGradient.aegisGoldGradient)
                .foregroundStyle(Color.aegisInk)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .disabled(isPurchasing)
        }
        .padding(16)
        .background(Color.aegisNavyLight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isPopular ? Color.aegisGoldMid.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    PurchaseView()
}
