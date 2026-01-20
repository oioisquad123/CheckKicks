//
//  AegisConfidenceBadge.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/11/26.
//  Phase 3: Extracted from ResultsView for reusability
//

import SwiftUI

/// Animated confidence score ring display with Aegis Gold design
/// Legal-compliant: Uses probabilistic language only
struct AegisConfidenceBadge: View {
    let confidenceLevel: AuthenticationResult.ConfidenceLevel
    let confidenceScore: Int

    @State private var isAnimated = false
    @State private var confidenceProgress: Double = 0

    var levelColor: Color {
        switch confidenceLevel {
        case .high: return .aegisSuccess
        case .moderate: return .aegisWarning
        case .low: return .aegisError
        case .unableToAssess: return .aegisGray
        }
    }

    var levelIcon: String {
        switch confidenceLevel {
        case .high: return "checkmark.circle.fill"
        case .moderate: return "questionmark.circle.fill"
        case .low: return "exclamationmark.circle.fill"
        case .unableToAssess: return "questionmark.circle.fill"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Confidence Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.aegisNavyElevated, lineWidth: 12)
                    .frame(width: 180, height: 180)

                // Progress ring
                Circle()
                    .trim(from: 0, to: confidenceProgress)
                    .stroke(
                        levelColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                // Center content
                VStack(spacing: 8) {
                    Image(systemName: levelIcon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(levelColor)
                        .scaleEffect(isAnimated ? 1 : 0.5)

                    Text("\(Int(confidenceProgress * 100))%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)

                    Text("Confidence Score")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                }
            }

            // Confidence Level text
            VStack(spacing: 6) {
                Text(confidenceLevel.displayName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(levelColor)
                    .opacity(isAnimated ? 1 : 0)
                    .offset(y: isAnimated ? 0 : 10)

                Text(confidenceLevel.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimated ? 1 : 0)
                    .offset(y: isAnimated ? 0 : 5)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimated = true
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                confidenceProgress = Double(confidenceScore) / 100.0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.aegisNavy.ignoresSafeArea()

        VStack(spacing: 40) {
            AegisConfidenceBadge(
                confidenceLevel: .high,
                confidenceScore: 92
            )

            AegisConfidenceBadge(
                confidenceLevel: .low,
                confidenceScore: 35
            )
        }
    }
}
