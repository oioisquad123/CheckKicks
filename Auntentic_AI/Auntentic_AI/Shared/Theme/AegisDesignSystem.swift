//
//  AegisDesignSystem.swift
//  Auntentic_AI
//
//  Created on January 2, 2026.
//  Aegis Gold Design System - Premium Shield Theme
//

import SwiftUI

// MARK: - Aegis Color Palette

extension Color {
    // MARK: - Primary Brand Colors

    /// Deep background from icon's outer edges - #0D1226
    static let aegisNavy = Color(red: 0.05, green: 0.07, blue: 0.15)

    /// Slightly lighter navy for cards/elevated surfaces - #1A1F38
    static let aegisNavyLight = Color(red: 0.10, green: 0.12, blue: 0.22)

    /// Even lighter for subtle elevation - #252B45
    static let aegisNavyElevated = Color(red: 0.145, green: 0.17, blue: 0.27)

    // MARK: - Gold Gradient Colors

    /// Bright highlight gold - #FFF299
    static let aegisGoldLight = Color(red: 1.0, green: 0.95, blue: 0.6)

    /// Mid-tone true gold - #FFD700
    static let aegisGoldMid = Color(red: 1.0, green: 0.84, blue: 0.0)

    /// Dark metallic shadow gold - #DAA520
    static let aegisGoldDark = Color(red: 0.85, green: 0.65, blue: 0.13)

    // MARK: - Functional Colors

    /// High contrast text on gold backgrounds
    static let aegisInk = Color.black.opacity(0.85)

    /// Primary text on navy backgrounds
    static let aegisWhite = Color.white.opacity(0.95)

    /// Secondary text on navy backgrounds
    static let aegisGray = Color.white.opacity(0.60)

    /// Muted text/disabled state
    static let aegisMuted = Color.white.opacity(0.40)

    // MARK: - Semantic Colors

    /// Success/Authentic - Emerald green
    static let aegisSuccess = Color(red: 0.13, green: 0.77, blue: 0.37) // #22C55E

    /// Warning/Caution - Amber
    static let aegisWarning = Color(red: 0.96, green: 0.62, blue: 0.04) // #F59E0B

    /// Error/Fake - Red
    static let aegisError = Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444

    /// Info/Inconclusive - Blue
    static let aegisInfo = Color(red: 0.23, green: 0.51, blue: 0.96) // #3B82F6
}

// MARK: - Aegis Gradients

extension LinearGradient {
    /// Signature metallic gold gradient from the icon
    static let aegisGoldGradient = LinearGradient(
        gradient: Gradient(colors: [.aegisGoldLight, .aegisGoldMid, .aegisGoldDark]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Horizontal gold gradient for buttons
    static let aegisGoldHorizontal = LinearGradient(
        gradient: Gradient(colors: [.aegisGoldLight, .aegisGoldMid, .aegisGoldDark]),
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Subtle background gradient
    static let aegisNavyGradient = LinearGradient(
        gradient: Gradient(colors: [.aegisNavyLight, .aegisNavy]),
        startPoint: .top,
        endPoint: .bottom
    )

    /// Card background with depth
    static let aegisCardGradient = LinearGradient(
        gradient: Gradient(colors: [.aegisNavyElevated, .aegisNavyLight]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Aegis Primary Button

struct AegisPrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.mediumImpact()
            action()
        }) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(LinearGradient.aegisGoldGradient)
            .foregroundStyle(Color.aegisInk)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .aegisGoldMid.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(AegisPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Aegis Secondary Button

struct AegisSecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.lightImpact()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.aegisNavyElevated)
            .foregroundStyle(Color.aegisGoldMid)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LinearGradient.aegisGoldGradient, lineWidth: 1.5)
                    .opacity(0.5)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(AegisPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Aegis Google Sign-In Button

/// Google Sign-In button with Aegis Gold design system styling
/// Uses navy background with gold border to match app theme
struct AegisGoogleButton: View {
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.lightImpact()
            action()
        }) {
            HStack(spacing: 10) {
                // Official Google "G" multicolor logo
                GoogleLogoView()
                    .frame(width: 20, height: 20)

                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.aegisNavyElevated)
            .foregroundStyle(Color.aegisGoldMid)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LinearGradient.aegisGoldGradient, lineWidth: 1.5)
                    .opacity(0.5)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(AegisPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Google Logo View

/// Official Google "G" logo using SwiftUI shapes
/// Uses official Google brand colors: Blue #4285F4, Red #EA4335, Yellow #FBBC05, Green #34A853
struct GoogleLogoView: View {
    // Official Google brand colors
    private let googleBlue = Color(red: 0.259, green: 0.522, blue: 0.957)   // #4285F4
    private let googleRed = Color(red: 0.918, green: 0.263, blue: 0.208)    // #EA4335
    private let googleYellow = Color(red: 0.984, green: 0.737, blue: 0.020) // #FBBC05
    private let googleGreen = Color(red: 0.204, green: 0.659, blue: 0.325)  // #34A853

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let outerRadius = size / 2
            let innerRadius = size / 4
            let strokeWidth = size / 4

            ZStack {
                // Blue arc (right side, top portion)
                ArcShape(startAngle: -45, endAngle: 45, clockwise: false)
                    .stroke(googleBlue, lineWidth: strokeWidth)
                    .frame(width: outerRadius * 1.5, height: outerRadius * 1.5)

                // Green arc (bottom right)
                ArcShape(startAngle: 45, endAngle: 135, clockwise: false)
                    .stroke(googleGreen, lineWidth: strokeWidth)
                    .frame(width: outerRadius * 1.5, height: outerRadius * 1.5)

                // Yellow arc (bottom left)
                ArcShape(startAngle: 135, endAngle: 180, clockwise: false)
                    .stroke(googleYellow, lineWidth: strokeWidth)
                    .frame(width: outerRadius * 1.5, height: outerRadius * 1.5)

                // Red arc (top)
                ArcShape(startAngle: 180, endAngle: 315, clockwise: false)
                    .stroke(googleRed, lineWidth: strokeWidth)
                    .frame(width: outerRadius * 1.5, height: outerRadius * 1.5)

                // Blue horizontal bar (the "arm" of the G)
                Rectangle()
                    .fill(googleBlue)
                    .frame(width: size * 0.45, height: strokeWidth)
                    .offset(x: size * 0.1, y: 0)
            }
            .position(center)
        }
    }
}

// MARK: - Arc Shape Helper

/// Helper shape for drawing arcs
struct ArcShape: Shape {
    let startAngle: Double
    let endAngle: Double
    let clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: clockwise
        )

        return path
    }
}

// MARK: - Aegis Ghost Button

struct AegisGhostButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightImpact()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(Color.aegisGoldMid)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Button Press Style

struct AegisPressStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                isPressed = pressed
            }
    }
}

// MARK: - Aegis Card

struct AegisCard<Content: View>: View {
    let content: Content
    var showGoldBorder: Bool = true

    init(showGoldBorder: Bool = true, @ViewBuilder content: () -> Content) {
        self.showGoldBorder = showGoldBorder
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(LinearGradient.aegisGoldGradient, lineWidth: 1)
                    .opacity(showGoldBorder ? 0.3 : 0)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Aegis Stat Card

struct AegisStatCard: View {
    let icon: String
    let value: String
    let label: String
    var isInteractive: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            // Icon with gold glow
            ZStack {
                Circle()
                    .fill(Color.aegisGoldMid.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.aegisGoldMid)
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.aegisWhite)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.aegisGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.aegisNavyLight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Aegis Background Modifier

struct AegisBackground: ViewModifier {
    var showWatermark: Bool = false

    func body(content: Content) -> some View {
        ZStack {
            // Base gradient background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()

            // Subtle shield watermark (optional)
            if showWatermark {
                GeometryReader { geo in
                    Image(systemName: "shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.aegisGoldMid)
                        .opacity(0.02)
                        .frame(width: geo.size.width * 0.6)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }

            content
        }
        .preferredColorScheme(.dark)
    }
}

extension View {
    func withAegisBackground(showWatermark: Bool = false) -> some View {
        modifier(AegisBackground(showWatermark: showWatermark))
    }
}

// MARK: - Aegis Navigation Bar Style

struct AegisNavigationBar: View {
    let title: String
    var subtitle: String? = nil
    var leadingAction: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            if let leadingAction = leadingAction {
                Button(action: leadingAction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisGoldMid)
                        .frame(width: 44, height: 44)
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                }
            }

            Spacer()

            if let trailingAction = trailingAction, let trailingIcon = trailingIcon {
                Button(action: trailingAction) {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisGoldMid)
                        .frame(width: 44, height: 44)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
}

// MARK: - Aegis Loading Spinner

struct AegisSpinner: View {
    var size: CGFloat = 44
    var lineWidth: CGFloat = 4

    @State private var rotation: Double = 0
    @State private var trimEnd: CGFloat = 0.7

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Animated arc
            Circle()
                .trim(from: 0, to: trimEnd)
                .stroke(
                    LinearGradient.aegisGoldGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(Angle(degrees: rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                trimEnd = 0.3
            }
        }
    }
}

// MARK: - Aegis Section Header

struct AegisSectionHeader: View {
    let title: String
    var showDivider: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.aegisGoldMid)
                .tracking(1.2)

            if showDivider {
                Rectangle()
                    .fill(LinearGradient.aegisGoldGradient)
                    .frame(height: 1)
                    .opacity(0.3)
            }
        }
    }
}

// MARK: - Aegis Confidence Level Badge (Legal Compliant)

struct AegisConfidenceLevelBadge: View {
    let confidenceLevel: AuthenticationResult.ConfidenceLevel
    @State private var isAnimated = false

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
        VStack(spacing: 16) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(levelColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimated ? 1.1 : 0.9)

                // Inner circle
                Circle()
                    .fill(levelColor.opacity(0.3))
                    .frame(width: 100, height: 100)

                Image(systemName: levelIcon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(levelColor)
                    .scaleEffect(isAnimated ? 1.0 : 0.5)
            }

            Text(confidenceLevel.displayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(levelColor)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                isAnimated = true
            }
        }
    }
}

// MARK: - Aegis Pill Badge

struct AegisPillBadge: View {
    let text: String
    var icon: String? = nil
    var style: BadgeStyle = .info

    enum BadgeStyle {
        case info, warning, success, error

        var backgroundColor: Color {
            switch self {
            case .info: return .aegisInfo.opacity(0.2)
            case .warning: return .aegisWarning.opacity(0.2)
            case .success: return .aegisSuccess.opacity(0.2)
            case .error: return .aegisError.opacity(0.2)
            }
        }

        var textColor: Color {
            switch self {
            case .info: return .aegisInfo
            case .warning: return .aegisWarning
            case .success: return .aegisSuccess
            case .error: return .aegisError
            }
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(style.textColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(style.backgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - Aegis Step Indicator

struct AegisStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(fillColor(for: index))
                    .frame(width: index == currentStep ? 28 : 10, height: 10)
                    .overlay(
                        Capsule()
                            .stroke(strokeColor(for: index), lineWidth: 1.5)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
    }

    private func fillColor(for index: Int) -> Color {
        if index < currentStep {
            return .aegisGoldMid // Completed
        } else if index == currentStep {
            return .aegisGoldMid.opacity(0.3) // Current
        } else {
            return .clear // Future
        }
    }

    private func strokeColor(for index: Int) -> Color {
        if index <= currentStep {
            return .aegisGoldMid
        } else {
            return .aegisMuted
        }
    }
}

// MARK: - Aegis Tips Card

struct AegisTipsCard: View {
    let tips: [(icon: String, text: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                HStack(spacing: 16) {
                    Image(systemName: tip.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.aegisGoldMid)
                        .frame(width: 28)

                    Text(tip.text)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.aegisWhite)

                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)

                if index < tips.count - 1 {
                    Rectangle()
                        .fill(Color.aegisGoldMid.opacity(0.1))
                        .frame(height: 1)
                        .padding(.leading, 64)
                }
            }
        }
        .background(Color.aegisNavyLight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.aegisGoldMid.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Aegis Disclaimer

struct AegisDisclaimer: View {
    var text: String = "This result is AI-assisted and does not guarantee authenticity."

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.aegisMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }
}

// MARK: - Aegis Hero Shield

struct AegisHeroShield: View {
    var size: CGFloat = 200
    @State private var isAnimated = false
    @State private var isGlowing = false
    @State private var rotationAmount: Double = 0

    var body: some View {
        ZStack {
            // High-end Glow pulse
            Image("LuxuriousShield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 1.2, height: size * 1.2)
                .blur(radius: 40)
                .opacity(isGlowing ? 0.6 : 0.3)
                .scaleEffect(isGlowing ? 1.1 : 1.0)

            // Main Luxurious Shield
            Image("LuxuriousShield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
                .shadow(color: Color.aegisGoldMid.opacity(0.4), radius: 30, y: 15)
                .rotationEffect(.degrees(rotationAmount))
                .scaleEffect(isAnimated ? 1.0 : 0.8)
                .opacity(isAnimated ? 1.0 : 0)
        }
        .onAppear {
            // Entry animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimated = true
            }

            // Premium "Circle" animation - spins 360 degrees twice then settles at 0
            withAnimation(.spring(response: 1.5, dampingFraction: 0.8).delay(0.5)) {
                rotationAmount = 360 * 2
            }

            // Glow pulse
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Aegis Photo Card

struct AegisPhotoCard: View {
    let image: UIImage?
    let title: String
    var status: PhotoStatus = .empty

    enum PhotoStatus {
        case empty, captured, warning

        var badgeColor: Color {
            switch self {
            case .empty: return .aegisMuted
            case .captured: return .aegisSuccess
            case .warning: return .aegisWarning
            }
        }

        var badgeIcon: String {
            switch self {
            case .empty: return "camera"
            case .captured: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.aegisNavyElevated)
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 32, weight: .light))
                                .foregroundStyle(Color.aegisMuted)
                        )
                }

                // Status badge
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: status.badgeIcon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(status == .empty ? Color.aegisMuted : .white)
                            .padding(6)
                            .background(status.badgeColor)
                            .clipShape(Circle())
                            .padding(8)
                    }
                    Spacer()
                }
            }

            // Title
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.aegisGray)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.aegisNavyLight)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Aegis Shutter Button

struct AegisShutterButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.mediumImpact()
            action()
        }) {
            ZStack {
                // Outer gold ring
                Circle()
                    .stroke(LinearGradient.aegisGoldGradient, lineWidth: 4)
                    .frame(width: 80, height: 80)

                // Inner white circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(AegisPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Aegis Progress Bar

struct AegisProgressBar: View {
    let progress: Double
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.aegisNavyElevated)
                    .frame(height: height)

                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(LinearGradient.aegisGoldGradient)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Preview

#Preview("Aegis Components") {
    ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 24) {
            AegisSectionHeader(title: "Primary Button")
            AegisPrimaryButton(title: "Authenticate", icon: "camera.fill") {}

            AegisSectionHeader(title: "Secondary Button")
            AegisSecondaryButton(title: "View History", icon: "clock") {}

            AegisSectionHeader(title: "Cards")
            HStack(spacing: 16) {
                AegisStatCard(icon: "clock.arrow.circlepath", value: "12", label: "History")
                AegisStatCard(icon: "star.fill", value: "3", label: "Free Checks")
            }

            AegisSectionHeader(title: "Loading")
            AegisSpinner()
        }
        .padding(24)
    }
    .withAegisBackground(showWatermark: true)
}
