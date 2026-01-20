//
//  CreditBalanceView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/10/26.
//  Task 14: Toolbar credit balance display component
//

import SwiftUI

/// Compact credit balance display for toolbar
struct CreditBalanceView: View {
    @Environment(\.creditManager) private var creditManager

    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightImpact()
            onTap()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))

                Text("\(creditManager.credits)")
                    .font(.system(size: 14, weight: .bold))
                    .monospacedDigit()
            }
            .foregroundStyle(Color.aegisGoldMid)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.aegisNavyElevated)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.aegisGoldMid.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.aegisNavy.ignoresSafeArea()

        CreditBalanceView {
            // Tap action handled by parent view
        }
    }
}
