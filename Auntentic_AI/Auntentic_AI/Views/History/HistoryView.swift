//
//  HistoryView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 23: Authentication History Screen
//  Redesigned with Aegis Gold theme
//

import SwiftUI

/// Display user's past authentication checks with Aegis Gold theme
struct HistoryView: View {
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.authHistoryService) private var historyService
    @Environment(\.networkMonitor) private var networkMonitor

    @State private var records: [AuthenticationHistoryService.AuthenticationRecord] = []
    @State private var isLoading = true
    @State private var currentError: AppError?
    @State private var totalCount = 0

    var body: some View {
        ZStack {
            // Aegis Background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Offline Banner
                OfflineBanner()

                Group {
                    if isLoading {
                        loadingView
                    } else if let error = currentError {
                        aegisErrorView(error: error)
                    } else if records.isEmpty {
                        emptyStateView
                    } else {
                        historyListView
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: refreshHistory) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.aegisGoldMid)
                        .frame(width: 36, height: 36)
                        .background(Color.aegisNavyLight)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.aegisGoldMid.opacity(0.3), lineWidth: 1)
                        )
                }
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
            }
        }
        .task {
            await loadHistory()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Header skeleton
                HStack {
                    AegisSkeletonView(width: 140, height: 14)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Card skeletons
                ForEach(0..<5, id: \.self) { _ in
                    AegisHistorySkeletonRow()
                }
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Error View with Aegis styling

    private func aegisErrorView(error: AppError) -> some View {
        VStack(spacing: 24) {
            // Error icon
            ZStack {
                Circle()
                    .fill(Color.aegisError.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.aegisError)
            }

            VStack(spacing: 8) {
                Text("Unable to Load History")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                Text(error.errorDescription ?? "Unknown error")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.aegisGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            AegisPrimaryButton(title: "Try Again", icon: "arrow.clockwise") {
                Task { await loadHistory() }
            }
            .padding(.horizontal, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 32) {
            // Shield watermark with glow
            ZStack {
                // Outer glow
                Image("LuxuriousShield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .opacity(0.15)
                    .blur(radius: 20)

                // Main shield
                Image("LuxuriousShield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .opacity(0.4)

                // Clock icon overlay
                Image(systemName: "clock")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color.aegisGoldMid.opacity(0.5))
            }

            VStack(spacing: 12) {
                Text("No Checks Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                Text("Start your first sneaker authentication\nto see your history here")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            AegisPrimaryButton(title: "Start Authentication", icon: "camera.fill") {
                coordinator.pop()
                coordinator.navigateToPhotoCapture()
            }
            .padding(.horizontal, 48)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - History List View

    private var historyListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Section header
                HStack {
                    Text("\(totalCount) authentication\(totalCount == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.aegisGray)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // History cards
                LazyVStack(spacing: 12) {
                    ForEach(records, id: \.id) { record in
                        AegisHistoryCard(record: record)
                            .padding(.horizontal, 24)
                    }
                }

                // AI Disclaimer at bottom
                AegisDisclaimer()
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
            }
        }
        .refreshable {
            await loadHistory()
        }
    }

    // MARK: - Actions

    private func loadHistory() async {
        isLoading = true
        currentError = nil

        // Check network connectivity first
        guard networkMonitor.isConnected else {
            currentError = .noInternet
            isLoading = false
            return
        }

        do {
            records = try await historyService.fetchHistory(limit: 50)
            totalCount = records.count

            // Try to get exact count
            if let count = try? await historyService.fetchHistoryCount() {
                totalCount = count
            }
        } catch {
            currentError = AppError.from(error)
        }

        isLoading = false
    }

    private func refreshHistory() {
        Task {
            await loadHistory()
        }
    }
}

// MARK: - Aegis History Card

struct AegisHistoryCard: View {
    let record: AuthenticationHistoryService.AuthenticationRecord

    @State private var isPressed = false

    // Note: record.verdict now stores confidence level (high/moderate/low)
    // for legal compliance - we use probabilistic language only
    private var confidenceColor: Color {
        switch record.verdict.lowercased() {
        case "high":
            return .aegisSuccess
        case "low":
            return .aegisError
        default: // "moderate" or legacy values
            return .aegisWarning
        }
    }

    private var confidenceIcon: String {
        switch record.verdict.lowercased() {
        case "high":
            return "checkmark.circle.fill"
        case "low":
            return "exclamationmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    private var confidenceText: String {
        switch record.verdict.lowercased() {
        case "high":
            return "High Confidence"
        case "low":
            return "Low Confidence"
        default:
            return "Moderate Confidence"
        }
    }

    private var formattedDate: String {
        guard let date = record.createdAt else { return "Unknown date" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private var fullDate: String {
        guard let date = record.createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        Button(action: {
            // TODO: Navigate to detail view
            HapticManager.lightImpact()
        }) {
            HStack(spacing: 16) {
                // Confidence Icon with background
                ZStack {
                    Circle()
                        .fill(confidenceColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: confidenceIcon)
                        .font(.system(size: 28))
                        .foregroundStyle(confidenceColor)
                }

                // Details
                VStack(alignment: .leading, spacing: 6) {
                    // Confidence level text
                    Text(confidenceText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(confidenceColor)

                    // Confidence score and date
                    HStack(spacing: 8) {
                        // Confidence score pill
                        Text("\(record.confidence)%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.aegisInk)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(LinearGradient.aegisGoldGradient)
                            )

                        Text("•")
                            .foregroundStyle(Color.aegisMuted)

                        // Date
                        Text(formattedDate)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }

                    // Sneaker model if available
                    if let model = record.sneakerModel, !model.isEmpty {
                        Text(model)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.aegisMuted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.aegisGoldMid.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.aegisNavyLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(AegisCardButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(confidenceText), \(record.confidence) percent confidence score, \(fullDate)")
    }
}

// MARK: - Aegis Card Button Style

struct AegisCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Aegis Skeleton Views

struct AegisSkeletonView: View {
    let width: CGFloat?
    let height: CGFloat

    @State private var phase: CGFloat = 0

    init(width: CGFloat? = nil, height: CGFloat = 20) {
        self.width = width
        self.height = height
    }

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.aegisNavyElevated, location: 0),
                .init(color: Color.aegisNavyLight.opacity(0.8), location: 0.3),
                .init(color: Color.aegisNavyElevated, location: 0.6),
                .init(color: Color.aegisNavyLight.opacity(0.8), location: 1)
            ]),
            startPoint: .init(x: phase - 1, y: 0.5),
            endPoint: .init(x: phase, y: 0.5)
        )
        .frame(width: width, height: height)
        .cornerRadius(height / 4)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 2
            }
        }
    }
}

struct AegisHistorySkeletonRow: View {
    var body: some View {
        HStack(spacing: 16) {
            // Icon placeholder
            AegisSkeletonView(width: 56, height: 56)
                .cornerRadius(28)

            VStack(alignment: .leading, spacing: 8) {
                AegisSkeletonView(width: 140, height: 18)
                HStack(spacing: 8) {
                    AegisSkeletonView(width: 45, height: 20)
                    AegisSkeletonView(width: 60, height: 14)
                }
            }

            Spacer()

            AegisSkeletonView(width: 20, height: 20)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aegisNavyLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.aegisGoldMid.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview

#Preview("With Data") {
    NavigationStack {
        HistoryView()
    }
    .environment(\.navigationCoordinator, NavigationCoordinator())
    .environment(\.authHistoryService, AuthenticationHistoryService())
}

#Preview("Empty State") {
    NavigationStack {
        HistoryView()
    }
    .environment(\.navigationCoordinator, NavigationCoordinator())
    .environment(\.authHistoryService, AuthenticationHistoryService())
}
