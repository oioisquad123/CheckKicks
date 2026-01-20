Here is the full content formatted as a clean Markdown file. You can copy the code block below, save it as AegisDesignSystem.md, and upload it to your Claude Code environment.

Markdown

# Design Framework: Aegis Gold System

**Context:** iOS App Design System based on the "Premium Shield" icon.
**Visual Style:** Dark Mode centric, Metallic Gradients, High Contrast, Luxury Tech.
**Reference Icon:** Gold Shield with checkmark on deep navy background.

---

## 1. Visual Analysis & Philosophy
* **Dominant Colors:** Deep Midnight Navy (Background) & Metallic Gold (Primary Action).
* **Texture:** Subtle gradients, gloss finishes, linear tech patterns.
* **Shape Language:** Softened corners (Continuous Curvature), sturdy strokes, shield motifs.
* **Vibe:** Professional, Secure, Verified, Premium.

---

## 2. Color Palette (SwiftUI Extensions)

These colors are extracted directly from the icon's gradient and shadow profile. Add this `Color` extension to your project.

```swift
import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors
    /// The deep background color from the icon's outer edges
    static let aegisNavy = Color(red: 0.05, green: 0.07, blue: 0.15) // Hex: #0D1226
    
    /// A slightly lighter navy for cards/lists to create depth
    static let aegisNavyLight = Color(red: 0.10, green: 0.12, blue: 0.22) // Hex: #1A1F38
    
    // MARK: - Gold Gradients (The Shield)
    /// Bright highlight gold
    static let aegisGoldLight = Color(red: 1.0, green: 0.95, blue: 0.6) // Hex: #FFF299
    
    /// Mid-tone true gold
    static let aegisGoldMid = Color(red: 1.0, green: 0.84, blue: 0.0) // Hex: #FFD700
    
    /// Dark metallic shadow gold
    static let aegisGoldDark = Color(red: 0.85, green: 0.65, blue: 0.13) // Hex: #DAA520
    
    // MARK: - Functional Colors
    /// Use for text on top of Gold backgrounds (High Contrast)
    static let aegisInk = Color.black.opacity(0.85)
    
    /// Use for text on Navy backgrounds
    static let aegisWhite = Color.white.opacity(0.95)
    static let aegisGray = Color.white.opacity(0.60)
}

extension LinearGradient {
    /// The signature metallic gradient from the icon
    static let aegisGoldGradient = LinearGradient(
        gradient: Gradient(colors: [.aegisGoldLight, .aegisGoldMid, .aegisGoldDark]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Subtle background shine
    static let aegisNavyGradient = LinearGradient(
        gradient: Gradient(colors: [.aegisNavyLight, .aegisNavy]),
        startPoint: .top,
        endPoint: .bottom
    )
}
3. Typography Guidelines
Following Apple's guidelines, we use San Francisco (SF Pro) but adjust weights to match the "strong" nature of the shield.

Headers: SF Pro Display, Bold or Heavy. Color: .aegisWhite.

Body: SF Pro Text, Regular. Color: .aegisGray (reduces eye strain on dark mode).

Monospaced: SF Mono. Use for codes, verification strings, or security keys. Color: .aegisGoldMid.

4. UI Components (SwiftUI)
A. The "Verified" Primary Button
Reference: The checkmark in the icon. This button uses the gold gradient for maximum visibility. We use dark text on gold to satisfy Apple's contrast accessibility requirements.

Swift

struct AegisPrimaryButton: View {
    var title: String
    var icon: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .fontWeight(.bold)
                }
                Text(title)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient.aegisGoldGradient)
            .foregroundStyle(Color.aegisInk) // Dark text on Gold for readability
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .aegisGoldMid.opacity(0.4), radius: 10, x: 0, y: 4) // Glow effect
        }
    }
}
B. The "Secure" Card
Reference: The dark shield background. Used for grouping content. It uses a subtle stroke to mimic the metallic rim of the shield.

Swift

struct AegisCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color.aegisNavyLight)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(LinearGradient.aegisGoldGradient, lineWidth: 1)
                    .opacity(0.3) // Subtle metallic rim
            )
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}
C. The Background View
This ensures the app always feels like part of the icon's universe. Apply this modifier to your root Views.

Swift

struct AegisBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Base background
            LinearGradient.aegisNavyGradient
                .ignoresSafeArea()
            
            // Subtle Grid/Tech texture (Optional, references the icon's background lines)
            GeometryReader { geo in
                Image(systemName: "shield.fill") // Conceptual watermark
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.aegisGoldMid)
                    .opacity(0.02)
                    .frame(width: geo.size.width * 0.8)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            
            content
        }
        .preferredColorScheme(.dark) // Force Dark Mode look
    }
}

extension View {
    func withAegisBackground() -> some View {
        modifier(AegisBackground())
    }
}
5. Apple Design Tips Implementation Checklist
Check generated views against these specific points derived from Apple's Design Tips:

Touch Targets: Ensure all tappable AegisPrimaryButton areas are at least 44x44 pt.

Legibility: Do not put Gold text on the Navy background unless it is "Large Title" size. For body text, use aegisGray or aegisWhite.

Alignment: Use standard SwiftUI padding (.padding()) which defaults to 16pt, keeping the UI breathable.

Haptics: Since this is a "Security" app concept, use haptic feedback (Success/Error) when buttons are pressed to reinforce the "tactile" feel of the metallic icon.

SF Symbols: Use Symbols that match the stroke weight of the typography. (e.g., shield.fill, checkmark.shield, lock.fill).