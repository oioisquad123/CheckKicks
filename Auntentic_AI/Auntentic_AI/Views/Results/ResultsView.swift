//
//  ResultsView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/29/25.
//  Updated: January 3, 2026 - Legal Compliance (Probabilistic Language)
//

import SwiftUI

/// View displaying sneaker AI analysis results with Aegis Gold design
/// IMPORTANT: Uses probabilistic language only - no definitive authentication claims
struct ResultsView: View {
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.creditManager) private var creditManager
    @Environment(\.appReviewManager) private var appReviewManager
    @State private var observationsExpanded = true
    @State private var isAppeared = false
    @State private var showPurchaseSheet = false

    let result: AuthenticationResult

    /// Show low credits prompt when balance is 2 or less
    private var showLowCreditsPrompt: Bool {
        creditManager.credits <= 2
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Shoe Identification (if available)
                if let shoeId = result.shoeIdentification {
                    shoeIdentificationSection(shoeId, condition: result.condition)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : -10)
                }

                // Confidence Badge with Aegis styling
                AegisConfidenceBadge(confidenceLevel: result.confidenceLevel, confidenceScore: result.confidenceScore)
                    .padding(.top, result.shoeIdentification == nil ? 20 : 10)
                    .opacity(isAppeared ? 1 : 0)
                    .scaleEffect(isAppeared ? 1 : 0.8)

                // Disclaimer (always shown prominently)
                disclaimerSection
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 20)

                // Recommendation (if any)
                if let recommendation = result.recommendation {
                    recommendationSection(recommendation)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 25)
                }

                // Score Breakdown (if available)
                if let breakdown = result.breakdown {
                    breakdownSection(breakdown)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 30)
                }

                // Positive Indicators (if any and high confidence)
                if let indicators = result.positiveIndicators, !indicators.isEmpty, result.confidenceLevel == .high {
                    positiveIndicatorsSection(indicators)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 35)
                }

                // Concerns (if any)
                if let concerns = result.concerns, !concerns.isEmpty {
                    concernsSection(concerns)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 38)
                }

                // Observations
                observationsSection
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 40)

                // Additional Photos Needed
                if let additionalPhotos = result.additionalPhotosNeeded, !additionalPhotos.isEmpty {
                    additionalPhotosSection(additionalPhotos)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 45)
                }

                // Low Credits Prompt (only show when credits ≤ 2)
                if showLowCreditsPrompt {
                    lowCreditsPromptSection
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 48)
                }

                Spacer(minLength: 20)

                // Action Buttons
                actionButtons
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 50)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .withAegisBackground()
        .sheet(isPresented: $showPurchaseSheet) {
            PurchaseView()
        }
        .navigationTitle("Analysis Results")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAppeared = true
            }
            HapticManager.resultReady()

            // Trigger rating prompt for high confidence results after a short delay
            // This gives the user time to see and appreciate the positive result
            if result.confidenceLevel == .high {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    appReviewManager.recordSuccessfulAuthentication()
                }
            }
        }
    }

    // MARK: - Shoe Identification Section

    private func shoeIdentificationSection(_ shoe: ShoeIdentification, condition: ShoeCondition?) -> some View {
        AegisCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 10) {
                    Image(systemName: "shoe.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisGoldMid)

                    Text("AI Identified")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aegisGoldMid)
                }

                // Model Name
                Text(shoe.displayName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                // Details Grid
                VStack(spacing: 12) {
                    // Colorway
                    HStack {
                        Text("Colorway")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                        Spacer()
                        Text(shoe.colorway)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.aegisWhite)
                    }

                    // Year
                    HStack {
                        Text("Release")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                        Spacer()
                        Text(shoe.estimatedYear)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.aegisWhite)
                    }

                    // Style Code (if available)
                    if let styleCode = shoe.styleCode {
                        HStack {
                            Text("Style Code")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.aegisGray)
                            Spacer()
                            Text(styleCode)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color.aegisWhite)
                        }
                    }

                    // Condition (if available)
                    if let condition = condition {
                        Divider()
                            .background(Color.aegisNavyElevated)

                        HStack {
                            Text("Condition")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.aegisGray)
                            Spacer()
                            Text(condition.rating)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(colorForCondition(condition.rating))
                        }

                        Text(condition.notes)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.aegisGray)
                            .lineSpacing(2)
                    }
                }
            }
        }
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        AegisCard(showGoldBorder: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisWarning)

                    Text("AI-Assisted Analysis Only")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aegisWarning)
                }

                Text("This assessment is for informational purposes only and should NOT be considered a guarantee of authenticity. AI analysis cannot replace professional authentication services. For high-value purchases, always consult a professional authenticator.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .lineSpacing(4)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.aegisWarning.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Recommendation Section

    private func recommendationSection(_ recommendation: String) -> some View {
        AegisCard(showGoldBorder: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisInfo)

                    Text("Recommendation")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aegisInfo)
                }

                Text(recommendation)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .lineSpacing(4)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.aegisInfo.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Breakdown Section

    private func breakdownSection(_ breakdown: ScoreBreakdown) -> some View {
        AegisCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Quality Score Breakdown")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                VStack(spacing: 12) {
                    ForEach(breakdown.allScores, id: \.name) { item in
                        HStack(spacing: 12) {
                            Text(item.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.aegisGray)
                                .frame(width: 110, alignment: .leading)

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background bar
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.aegisNavyElevated)
                                        .frame(height: 8)

                                    // Progress bar
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(colorForScore(item.score, max: item.maxScore))
                                        .frame(width: geometry.size.width * CGFloat(item.score) / CGFloat(item.maxScore), height: 8)
                                }
                            }
                            .frame(height: 8)

                            Text("\(item.score)/\(item.maxScore)")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundStyle(colorForScore(item.score, max: item.maxScore))
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                }

                // Total
                HStack {
                    Text("Confidence Score")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)
                    Spacer()
                    Text("\(result.confidenceScore)/100")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(colorForConfidenceLevel(result.confidenceLevel))
                }
                .padding(.top, 8)
                .padding(.horizontal, 4)
            }
        }
    }

    private func colorForScore(_ score: Int, max: Int) -> Color {
        let percentage = Double(score) / Double(max)
        if percentage >= 0.8 {
            return .aegisSuccess
        } else if percentage >= 0.5 {
            return .aegisWarning
        } else {
            return .aegisError
        }
    }

    // MARK: - Positive Indicators Section

    private func positiveIndicatorsSection(_ indicators: [String]) -> some View {
        AegisCard(showGoldBorder: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisSuccess)

                    Text("Positive Quality Indicators")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aegisSuccess)
                }

                ForEach(indicators, id: \.self) { indicator in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.aegisSuccess)

                        Text(indicator)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.aegisSuccess.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Concerns Section

    private func concernsSection(_ concerns: [String]) -> some View {
        AegisCard(showGoldBorder: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisError)

                    Text("Quality Concerns Observed")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aegisError)
                }

                ForEach(concerns, id: \.self) { concern in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.aegisError)

                        Text(concern)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.aegisError.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Observations Section

    private var observationsSection: some View {
        AegisCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header with expand/collapse
                Button(action: {
                    HapticManager.selectionChanged()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        observationsExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("AI Analysis Details")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.aegisWhite)

                        Spacer()

                        Image(systemName: observationsExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.aegisGoldMid)
                    }
                }

                // Observations list
                if observationsExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(result.observations.enumerated()), id: \.offset) { index, observation in
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: iconForObservation(index))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(colorForConfidenceLevel(result.confidenceLevel))
                                    .frame(width: 24)

                                Text(observation)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.aegisGray)
                                    .lineSpacing(3)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func iconForObservation(_ index: Int) -> String {
        let icons = [
            "eye.fill",
            "magnifyingglass",
            "doc.text.magnifyingglass",
            "sparkle",
            "square.and.pencil",
            "chart.bar.fill"
        ]
        return icons[index % icons.count]
    }

    // MARK: - Additional Photos Section

    private func additionalPhotosSection(_ photos: [String]) -> some View {
        AegisCard(showGoldBorder: false) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisInfo)

                    Text("Additional Photos Needed")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aegisInfo)
                }

                Text("For a more accurate analysis, please provide:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.aegisGray)

                ForEach(photos, id: \.self) { photo in
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.aegisInfo)

                        Text(photo)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.aegisWhite)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.aegisInfo.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Low Credits Prompt Section

    private var lowCreditsPromptSection: some View {
        AegisCard(showGoldBorder: true) {
            VStack(spacing: 16) {
                // Icon and Title
                HStack(spacing: 12) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.aegisGoldMid)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(creditManager.credits) credit\(creditManager.credits == 1 ? "" : "s") remaining")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.aegisWhite)

                        Text("Stock up to keep authenticating")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }

                    Spacer()
                }

                // CTA Button
                Button(action: {
                    HapticManager.lightImpact()
                    showPurchaseSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Get More Credits")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color.aegisGoldLight, Color.aegisGoldMid],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(Color.aegisInk)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 14) {
            // New Check Button
            AegisPrimaryButton(title: "New Check", icon: "camera.fill") {
                coordinator.startNewCheck()
            }

            // Done Button
            AegisGhostButton(title: "Done", icon: "house.fill") {
                coordinator.navigateBackToHome()
            }

            // Micro disclaimer
            AegisDisclaimer()
                .padding(.top, 8)
        }
    }

    // MARK: - Helpers

    private func colorForConfidenceLevel(_ level: AuthenticationResult.ConfidenceLevel) -> Color {
        switch level {
        case .high: return .aegisSuccess
        case .moderate: return .aegisWarning
        case .low: return .aegisError
        case .unableToAssess: return .aegisGray
        }
    }

    private func colorForCondition(_ rating: String) -> Color {
        switch rating.lowercased() {
        case "like new", "deadstock", "ds", "new":
            return .aegisSuccess
        case "excellent":
            return .aegisSuccess
        case "very good":
            return Color(red: 0.52, green: 0.8, blue: 0.09) // Lime
        case "good":
            return .aegisWarning
        case "fair":
            return Color(red: 0.98, green: 0.45, blue: 0.09) // Orange
        case "poor":
            return .aegisError
        default:
            return .aegisGray
        }
    }
}

// MARK: - Preview

#Preview("High Confidence") {
    NavigationStack {
        ResultsView(result: .mockHighConfidence)
    }
    .environment(\.navigationCoordinator, NavigationCoordinator())
    .environment(\.creditManager, CreditManager())
    .environment(\.appReviewManager, AppReviewManager())
}

#Preview("Low Confidence") {
    NavigationStack {
        ResultsView(result: .mockLowConfidence)
    }
    .environment(\.navigationCoordinator, NavigationCoordinator())
    .environment(\.creditManager, CreditManager())
    .environment(\.appReviewManager, AppReviewManager())
}

#Preview("Moderate Confidence") {
    NavigationStack {
        ResultsView(result: .mockModerateConfidence)
    }
    .environment(\.navigationCoordinator, NavigationCoordinator())
    .environment(\.creditManager, CreditManager())
    .environment(\.appReviewManager, AppReviewManager())
}
