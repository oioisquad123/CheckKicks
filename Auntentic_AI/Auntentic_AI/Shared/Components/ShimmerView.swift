//
//  ShimmerView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 19: Shimmer loading effect for skeleton screens
//

import SwiftUI

/// Shimmer loading effect for skeleton screens
struct ShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(.systemGray5), location: 0),
                .init(color: Color(.systemGray4), location: 0.3),
                .init(color: Color(.systemGray5), location: 0.6),
                .init(color: Color(.systemGray4), location: 1)
            ]),
            startPoint: .init(x: phase - 1, y: 0.5),
            endPoint: .init(x: phase, y: 0.5)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 2
            }
        }
    }
}

/// Skeleton placeholder with shimmer effect
struct SkeletonView: View {
    let width: CGFloat?
    let height: CGFloat

    init(width: CGFloat? = nil, height: CGFloat = 20) {
        self.width = width
        self.height = height
    }

    var body: some View {
        ShimmerView()
            .frame(width: width, height: height)
            .cornerRadius(height / 4)
    }
}

/// Skeleton card for loading states
struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(height: 24)
            SkeletonView(width: 200, height: 16)
            SkeletonView(width: 150, height: 16)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}

/// Skeleton for history list items
struct HistorySkeletonRow: View {
    var body: some View {
        HStack(spacing: 16) {
            // Icon placeholder
            SkeletonView(width: 44, height: 44)
                .cornerRadius(22)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(width: 120, height: 18)
                SkeletonView(width: 180, height: 14)
            }

            Spacer()

            SkeletonView(width: 24, height: 24)
        }
        .padding(.vertical, 12)
    }
}

/// Skeleton for results loading
struct ResultsSkeletonView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Verdict icon placeholder
            SkeletonView(width: 100, height: 100)
                .cornerRadius(50)

            // Title placeholder
            SkeletonView(width: 200, height: 32)

            // Confidence bar placeholder
            VStack(spacing: 8) {
                SkeletonView(height: 16)
                SkeletonView(height: 12)
            }
            .padding(.horizontal, 40)

            // Observations placeholder
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack(spacing: 12) {
                        SkeletonView(width: 24, height: 24)
                            .cornerRadius(12)
                        SkeletonView(height: 16)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
        .padding(.top, 40)
    }
}

/// Pulsing animation modifier
struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulsingAnimation() -> some View {
        modifier(PulseAnimation())
    }
}

/// Animated loading indicator with text
struct LoadingIndicator: View {
    let message: String
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(rotation))
            }
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

/// AI Analysis loading view with animated sparkles
struct AIAnalysisLoadingView: View {
    @State private var sparklePhase: CGFloat = 0
    @State private var textOpacity: Double = 1

    let messages = [
        "Analyzing sneaker details...",
        "Checking stitching patterns...",
        "Examining material quality...",
        "Verifying brand markings...",
        "Comparing with authentic samples...",
        "Generating verdict..."
    ]

    @State private var currentMessageIndex = 0

    var body: some View {
        VStack(spacing: 32) {
            // Animated AI icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(1 + sparklePhase * 0.2)

                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                // Sparkle icon
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(sparklePhase * 360))
            }

            // Progress text
            Text(messages[currentMessageIndex])
                .font(.headline)
                .foregroundColor(.primary)
                .opacity(textOpacity)
                .animation(.easeInOut(duration: 0.3), value: currentMessageIndex)

            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<messages.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentMessageIndex ? Color.purple : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.spring(), value: currentMessageIndex)
                }
            }
        }
        .onAppear {
            // Sparkle animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                sparklePhase = 1
            }

            // Message cycling
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
                withAnimation {
                    textOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentMessageIndex = (currentMessageIndex + 1) % messages.count
                    withAnimation {
                        textOpacity = 1
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Shimmer View") {
    VStack(spacing: 20) {
        SkeletonView(height: 24)
        SkeletonView(width: 200, height: 16)
        SkeletonCard()
    }
    .padding()
}

#Preview("History Skeleton") {
    List {
        ForEach(0..<5, id: \.self) { _ in
            HistorySkeletonRow()
        }
    }
}

#Preview("AI Analysis Loading") {
    AIAnalysisLoadingView()
}

#Preview("Results Skeleton") {
    ResultsSkeletonView()
}
