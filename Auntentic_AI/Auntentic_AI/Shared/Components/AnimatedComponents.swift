//
//  AnimatedComponents.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 19: Smooth animations and transitions
//

import SwiftUI

// MARK: - Animated Progress Bar

/// Animated progress bar with gradient fill
struct AnimatedProgressBar: View {
    let progress: Double
    let height: CGFloat
    let backgroundColor: Color
    let foregroundGradient: [Color]

    init(
        progress: Double,
        height: CGFloat = 12,
        backgroundColor: Color = Color(.systemGray5),
        foregroundGradient: [Color] = [.blue, .purple]
    ) {
        self.progress = progress
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundGradient = foregroundGradient
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)

                // Foreground
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: foregroundGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Animated Confidence Meter

/// Circular confidence meter with animation
struct AnimatedConfidenceMeter: View {
    let confidence: Int
    let size: CGFloat

    @State private var animatedProgress: Double = 0

    private var progress: Double {
        Double(confidence) / 100.0
    }

    private var color: Color {
        if confidence >= 80 {
            return .green
        } else if confidence >= 60 {
            return .orange
        } else {
            return .red
        }
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 12)

            // Animated progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 4) {
                Text("\(confidence)%")
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                Text("Confidence")
                    .font(.system(size: size * 0.1, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.3)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Animated Confidence Badge (Legal Compliant)

/// Animated confidence level badge with scale and color
/// Uses probabilistic language only - no definitive verdicts
struct AnimatedConfidenceBadge: View {
    let confidenceLevel: AuthenticationResult.ConfidenceLevel

    @State private var isAnimated = false

    private var icon: String {
        switch confidenceLevel {
        case .high:
            return "checkmark.circle.fill"
        case .moderate:
            return "questionmark.circle.fill"
        case .low:
            return "exclamationmark.circle.fill"
        case .unableToAssess:
            return "questionmark.circle.fill"
        }
    }

    private var color: Color {
        switch confidenceLevel {
        case .high:
            return .aegisSuccess
        case .moderate:
            return .aegisWarning
        case .low:
            return .aegisError
        case .unableToAssess:
            return .aegisGray
        }
    }

    private var title: String {
        switch confidenceLevel {
        case .high:
            return "High Confidence"
        case .moderate:
            return "Moderate Confidence"
        case .low:
            return "Low Confidence"
        case .unableToAssess:
            return "Unable to Assess"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Animated icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimated ? 1.1 : 0.8)

                // Icon background
                Circle()
                    .fill(color)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimated ? 1.0 : 0.5)

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimated ? 1.0 : 0.3)
                    .opacity(isAnimated ? 1.0 : 0.0)
            }

            // Title
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
                .opacity(isAnimated ? 1.0 : 0.0)
                .offset(y: isAnimated ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                isAnimated = true
            }
            // Trigger haptic based on confidence level
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                switch confidenceLevel {
                case .high:
                    HapticManager.success()
                case .moderate:
                    HapticManager.warning()
                case .low:
                    HapticManager.error()
                case .unableToAssess:
                    HapticManager.warning()
                }
            }
        }
    }
}

// MARK: - Animated List Item

/// Staggered animation for list items
struct AnimatedListItem<Content: View>: View {
    let index: Int
    let content: Content

    @State private var isVisible = false

    init(index: Int, @ViewBuilder content: () -> Content) {
        self.index = index
        self.content = content()
    }

    var body: some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Animated Card

/// Card with press animation
struct AnimatedCard<Content: View>: View {
    let content: Content
    var onTap: (() -> Void)?

    @State private var isPressed = false

    init(onTap: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.onTap = onTap
        self.content = content()
    }

    var body: some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(isPressed ? 0.05 : 0.1), radius: isPressed ? 4 : 10)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .onTapGesture {
                if onTap != nil {
                    HapticManager.cardPressed()
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                        onTap?()
                    }
                }
            }
    }
}

// MARK: - Animated Step Indicator

/// Animated step indicator for wizard flows
struct AnimatedStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.blue : Color(.systemGray4))
                    .frame(width: index == currentStep ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
    }
}

// MARK: - Bounce Animation Modifier

struct BounceAnimation: ViewModifier {
    @State private var isBouncing = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(isBouncing ? 1.0 : 0.8)
            .opacity(isBouncing ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
                    isBouncing = true
                }
            }
    }
}

extension View {
    func bounceIn(delay: Double = 0) -> some View {
        modifier(BounceAnimation(delay: delay))
    }
}

// MARK: - Slide Animation Modifier

struct SlideAnimation: ViewModifier {
    enum Direction {
        case left, right, top, bottom
    }

    let direction: Direction
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }

    private var xOffset: CGFloat {
        guard !isVisible else { return 0 }
        switch direction {
        case .left: return -30
        case .right: return 30
        default: return 0
        }
    }

    private var yOffset: CGFloat {
        guard !isVisible else { return 0 }
        switch direction {
        case .top: return -30
        case .bottom: return 30
        default: return 0
        }
    }
}

extension View {
    func slideIn(from direction: SlideAnimation.Direction, delay: Double = 0) -> some View {
        modifier(SlideAnimation(direction: direction, delay: delay))
    }
}

// MARK: - Fade Transition

extension AnyTransition {
    static var fadeSlide: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 20)),
            removal: .opacity.combined(with: .offset(y: -20))
        )
    }

    static var scaleOpacity: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }
}

// MARK: - Previews

#Preview("Progress Bar") {
    VStack(spacing: 20) {
        AnimatedProgressBar(progress: 0.75)
        AnimatedProgressBar(progress: 0.5, foregroundGradient: [.green, .mint])
        AnimatedProgressBar(progress: 0.25, foregroundGradient: [.orange, .red])
    }
    .padding()
}

#Preview("Confidence Meter") {
    HStack(spacing: 20) {
        AnimatedConfidenceMeter(confidence: 85, size: 120)
        AnimatedConfidenceMeter(confidence: 65, size: 120)
        AnimatedConfidenceMeter(confidence: 45, size: 120)
    }
}

#Preview("Confidence Badges") {
    VStack(spacing: 40) {
        AnimatedConfidenceBadge(confidenceLevel: .high)
        AnimatedConfidenceBadge(confidenceLevel: .moderate)
        AnimatedConfidenceBadge(confidenceLevel: .low)
    }
}

#Preview("Step Indicator") {
    VStack(spacing: 20) {
        AnimatedStepIndicator(currentStep: 0, totalSteps: 6)
        AnimatedStepIndicator(currentStep: 2, totalSteps: 6)
        AnimatedStepIndicator(currentStep: 5, totalSteps: 6)
    }
}
