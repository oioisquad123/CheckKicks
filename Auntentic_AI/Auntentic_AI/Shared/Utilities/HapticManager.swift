//
//  HapticManager.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 19: Haptic feedback for important actions
//

import UIKit
import SwiftUI

/// Manager for haptic feedback throughout the app
enum HapticManager {

    // MARK: - Impact Feedback

    /// Light impact - for subtle interactions
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact - for standard button taps
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy impact - for significant actions
    static func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft impact - for gentle feedback
    static func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Rigid impact - for firm feedback
    static func rigidImpact() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success notification - for successful operations
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning notification - for warnings or caution
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error notification - for errors or failures
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed - for picker/toggle changes
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - App-Specific Patterns

    /// Photo captured successfully
    static func photoCaptured() {
        mediumImpact()
    }

    /// Authentication started
    static func authenticationStarted() {
        softImpact()
    }

    /// Authentication result ready
    static func resultReady() {
        // Double tap pattern for result
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            mediumImpact()
        }
    }

    /// Authentic verdict
    static func authenticVerdict() {
        success()
    }

    /// Fake verdict
    static func fakeVerdict() {
        warning()
    }

    /// Inconclusive verdict
    static func inconclusiveVerdict() {
        lightImpact()
    }

    /// Button tap
    static func buttonTap() {
        lightImpact()
    }

    /// Card pressed
    static func cardPressed() {
        softImpact()
    }

    /// Navigation back
    static func navigationBack() {
        selectionChanged()
    }

    /// Refresh action
    static func refresh() {
        lightImpact()
    }
}

// MARK: - SwiftUI View Modifier

/// View modifier for haptic feedback on tap
struct HapticFeedbackModifier: ViewModifier {
    let style: HapticStyle

    enum HapticStyle {
        case light
        case medium
        case heavy
        case soft
        case success
        case warning
        case error
        case selection
    }

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        triggerHaptic()
                    }
            )
    }

    private func triggerHaptic() {
        switch style {
        case .light:
            HapticManager.lightImpact()
        case .medium:
            HapticManager.mediumImpact()
        case .heavy:
            HapticManager.heavyImpact()
        case .soft:
            HapticManager.softImpact()
        case .success:
            HapticManager.success()
        case .warning:
            HapticManager.warning()
        case .error:
            HapticManager.error()
        case .selection:
            HapticManager.selectionChanged()
        }
    }
}

extension View {
    /// Add haptic feedback on tap
    func hapticFeedback(_ style: HapticFeedbackModifier.HapticStyle = .light) -> some View {
        modifier(HapticFeedbackModifier(style: style))
    }
}

// MARK: - Animated Button Style with Haptic

/// Button style with scale animation and haptic feedback
struct AnimatedButtonStyle: ButtonStyle {
    let hapticStyle: HapticFeedbackModifier.HapticStyle

    init(haptic: HapticFeedbackModifier.HapticStyle = .medium) {
        self.hapticStyle = haptic
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    triggerHaptic()
                }
            }
    }

    private func triggerHaptic() {
        switch hapticStyle {
        case .light:
            HapticManager.lightImpact()
        case .medium:
            HapticManager.mediumImpact()
        case .heavy:
            HapticManager.heavyImpact()
        case .soft:
            HapticManager.softImpact()
        case .success:
            HapticManager.success()
        case .warning:
            HapticManager.warning()
        case .error:
            HapticManager.error()
        case .selection:
            HapticManager.selectionChanged()
        }
    }
}

/// Premium button style with gradient and animation
struct PremiumButtonStyle: ButtonStyle {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.gray
                    }
                }
            )
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .shadow(
                color: isEnabled ? .blue.opacity(0.3) : .clear,
                radius: configuration.isPressed ? 4 : 8,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed && isEnabled {
                    HapticManager.mediumImpact()
                }
            }
    }
}
