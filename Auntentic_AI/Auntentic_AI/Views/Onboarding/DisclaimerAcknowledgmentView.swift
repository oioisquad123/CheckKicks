//
//  DisclaimerAcknowledgmentView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 1/3/26.
//  First-time user acknowledgment for AI analysis disclaimer
//  Required for legal compliance - probabilistic language only
//

import SwiftUI

/// First-time user acknowledgment screen for AI analysis disclaimer
/// Users must acknowledge this before using the app for the first time
struct DisclaimerAcknowledgmentView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasAcknowledgedDisclaimer") private var hasAcknowledged = false
    @State private var isChecked = false
    @State private var showError = false

    var onAcknowledge: (() -> Void)?

    var body: some View {
        ZStack {
            // Background
            Color.aegisInk
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Key Points
                    keyPointsSection

                    // Full Disclaimer
                    fullDisclaimerSection

                    // Checkbox Agreement
                    checkboxSection

                    // Continue Button
                    continueButton

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
        }
        .alert("Please Accept Terms", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You must check the box to acknowledge that you understand this is AI-assisted analysis only.")
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.aegisWarning.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color.aegisWarning)
            }

            // Title
            Text("Important Notice")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.aegisWhite)

            // Subtitle
            Text("Please read and acknowledge before continuing")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.aegisGray)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Key Points Section

    private var keyPointsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What CheckKicks Provides:")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.aegisGoldMid)

            keyPoint(
                icon: "brain.head.profile",
                title: "AI-Assisted Analysis",
                description: "Our AI analyzes sneaker images to assess quality indicators and provide a confidence score."
            )

            keyPoint(
                icon: "chart.bar.fill",
                title: "Confidence Levels",
                description: "Results are expressed as High, Moderate, or Low confidence - never definitive verdicts."
            )

            keyPoint(
                icon: "info.circle.fill",
                title: "Informational Only",
                description: "This assessment is for informational purposes and should NOT be considered a guarantee."
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aegisNavyLight)
        )
    }

    private func keyPoint(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.aegisGoldMid)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.aegisWhite)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.aegisGray)
                    .lineSpacing(2)
            }
        }
    }

    // MARK: - Full Disclaimer Section

    private var fullDisclaimerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Full Disclaimer")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.aegisWarning)

            Text("""
CheckKicks uses artificial intelligence to analyze sneaker images and provide a confidence assessment based on observable quality indicators. This is NOT an authentication service.

Our AI cannot guarantee authenticity. The analysis is based on visual patterns and should be used as one of many factors when evaluating sneakers.

For high-value purchases, we strongly recommend:
• Professional authentication services
• Purchasing from authorized retailers
• Physical inspection by experts

By using CheckKicks, you acknowledge that:
• Results are probabilistic, not definitive
• AI analysis has inherent limitations
• CheckKicks is not liable for purchase decisions
• This service is for informational purposes only
""")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.aegisGray)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aegisNavyLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.aegisWarning.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Checkbox Section

    private var checkboxSection: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isChecked.toggle()
            }
            HapticManager.selectionChanged()
        }) {
            HStack(alignment: .top, spacing: 14) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(isChecked ? Color.aegisGoldMid : Color.aegisGray, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isChecked {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.aegisGoldMid)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.aegisInk)
                    }
                }

                Text("I understand that CheckKicks provides AI-assisted analysis only, not authentication, and that results should not be relied upon as a guarantee of authenticity.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.aegisWhite)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.aegisNavyElevated)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button(action: {
            if isChecked {
                hasAcknowledged = true
                HapticManager.success()
                onAcknowledge?()
                dismiss()
            } else {
                showError = true
                HapticManager.error()
            }
        }) {
            HStack(spacing: 10) {
                Text("Continue")
                    .font(.system(size: 17, weight: .bold))

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(isChecked ? Color.aegisInk : Color.aegisGray)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isChecked ? LinearGradient.aegisGoldGradient : LinearGradient(colors: [Color.aegisNavyElevated], startPoint: .leading, endPoint: .trailing))
            )
        }
        .disabled(!isChecked)
        .opacity(isChecked ? 1 : 0.6)
    }
}

// MARK: - Preview

#Preview {
    DisclaimerAcknowledgmentView()
}
