//
//  HomeView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Updated: January 3, 2026 - Aegis Gold Design System (Mockup Match)
//  Updated: January 3, 2026 - Legal compliance disclaimer acknowledgment
//  Updated: January 10, 2026 - Credit balance toolbar and purchase integration
//  Updated: January 11, 2026 - Fixed credit loading state check before actions
//

import SwiftUI
import OSLog

/// Main home screen with Aegis Gold premium design matching mockup
struct HomeView: View {
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "HomeView")
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.authenticationService) private var authService
    @Environment(\.authHistoryService) private var historyService
    @Environment(\.networkMonitor) private var networkMonitor
    @Environment(\.creditManager) private var creditManager

    @State private var showSignOutConfirmation = false
    @State private var showPurchaseSheet = false
    @State private var showSettingsSheet = false
    @State private var checksCount = 0
    @State private var isAppeared = false
    @State private var isCreditsLoaded = false

    private let tips: [(icon: String, text: String)] = [
        ("camera.viewfinder", "Take clear, multi-angle photos"),
        ("sun.max.fill", "Use proper lighting"),
        ("magnifyingglass", "Close-up shots preferred")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Offline Banner at top
            OfflineBanner()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Hero Shield
                    AegisHeroShield(size: 180)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .opacity(isAppeared ? 1 : 0)
                        .scaleEffect(isAppeared ? 1 : 0.8)

                    // Title Section
                    VStack(spacing: 8) {
                        Text("Analyze Your Sneakers")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.aegisWhite)
                            .multilineTextAlignment(.center)

                        Text("AI-powered quality analysis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 20)

                    // Primary CTA Button
                    if !networkMonitor.isConnected {
                        // No connection state
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 16, weight: .semibold))
                            Text("No Connection")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.aegisNavyElevated)
                        .foregroundStyle(Color.aegisGray)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 24)
                    } else if !isCreditsLoaded || creditManager.isLoading {
                        // Loading credits state
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(Color.aegisGoldMid)
                            Text("Loading...")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.aegisNavyElevated)
                        .foregroundStyle(Color.aegisGray)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 24)
                    } else {
                        // Ready state
                        AegisPrimaryButton(title: "Start Analysis", icon: nil) {
                            HapticManager.mediumImpact()
                            // Check credits before starting
                            if creditManager.hasCredits {
                                coordinator.navigateToPhotoCapture()
                            } else {
                                showPurchaseSheet = true
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    // Tips Card
                    AegisTipsCard(tips: tips)
                        .padding(.horizontal, 24)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 30)

                    // AI Disclaimer
                    AegisDisclaimer()
                        .padding(.top, 8)
                        .opacity(isAppeared ? 1 : 0)

                    Spacer(minLength: 40)
                }
            }
        }
        .withAegisBackground(showWatermark: false)
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .task {
            // Load credits first, then mark as loaded
            await creditManager.loadCredits()
            isCreditsLoaded = true
            // Load checks count in parallel
            await loadChecksCount()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAppeared = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 12) {
                    // Credit balance
                    CreditBalanceView {
                        showPurchaseSheet = true
                    }

                    // History button
                    if checksCount > 0 {
                        Button(action: { coordinator.navigateToHistory() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("\(checksCount)")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(Color.aegisGoldMid)
                        }
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showSettingsSheet = true }) {
                        Label("Settings", systemImage: "gearshape")
                    }

                    Button(action: { coordinator.navigateToHistory() }) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }

                    Divider()

                    Button(role: .destructive, action: { showSignOutConfirmation = true }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisGoldMid)
                }
            }
        }
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Sign Out", role: .destructive, action: handleSignOut)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showPurchaseSheet) {
            PurchaseView()
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
        }
        // Note: Disclaimer is now handled during onboarding flow
    }

    // MARK: - Actions

    private func handleSignOut() {
        Task {
            do {
                try await authService.signOut()
                coordinator.popToRoot()
                coordinator.navigateToAuth()
            } catch {
                logger.error("Sign out error: \(error.localizedDescription)")
            }
        }
    }

    private func loadChecksCount() async {
        do {
            checksCount = try await historyService.fetchHistoryCount()
        } catch {
            checksCount = 0
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(\.navigationCoordinator, NavigationCoordinator())
    .environment(\.authenticationService, AuthenticationService())
    .environment(\.authHistoryService, AuthenticationHistoryService())
    .environment(\.networkMonitor, NetworkMonitor.shared)
    .environment(\.creditManager, CreditManager())
}
