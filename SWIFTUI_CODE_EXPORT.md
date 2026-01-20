# CheckKicks SwiftUI Code Export
## All View Files for Design Reference

---

## FILE 1: AegisDesignSystem.swift

```swift
import SwiftUI

// MARK: - Aegis Color Palette

extension Color {
    // Primary Brand Colors
    static let aegisNavy = Color(red: 0.05, green: 0.07, blue: 0.15)
    static let aegisNavyLight = Color(red: 0.10, green: 0.12, blue: 0.22)
    static let aegisNavyElevated = Color(red: 0.145, green: 0.17, blue: 0.27)

    // Gold Gradient Colors
    static let aegisGoldLight = Color(red: 1.0, green: 0.95, blue: 0.6)
    static let aegisGoldMid = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let aegisGoldDark = Color(red: 0.85, green: 0.65, blue: 0.13)

    // Functional Colors
    static let aegisInk = Color.black.opacity(0.85)
    static let aegisWhite = Color.white.opacity(0.95)
    static let aegisGray = Color.white.opacity(0.60)
    static let aegisMuted = Color.white.opacity(0.40)

    // Semantic Colors
    static let aegisSuccess = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let aegisWarning = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let aegisError = Color(red: 0.94, green: 0.27, blue: 0.27)
    static let aegisInfo = Color(red: 0.23, green: 0.51, blue: 0.96)
}

extension LinearGradient {
    static let aegisGoldGradient = LinearGradient(
        gradient: Gradient(colors: [.aegisGoldLight, .aegisGoldMid, .aegisGoldDark]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let aegisNavyGradient = LinearGradient(
        gradient: Gradient(colors: [.aegisNavyLight, .aegisNavy]),
        startPoint: .top,
        endPoint: .bottom
    )
}

struct AegisPrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
        }
    }
}

struct AegisSecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
        }
    }
}

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

struct AegisStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 12) {
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
    }
}

struct AegisSpinner: View {
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(LinearGradient.aegisGoldGradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: 44, height: 44)
            .rotationEffect(Angle(degrees: rotation))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

extension View {
    func withAegisBackground(showWatermark: Bool = false) -> some View {
        ZStack {
            LinearGradient.aegisNavyGradient.ignoresSafeArea()
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
            self
        }
        .preferredColorScheme(.dark)
    }
}
```

---

## FILE 2: HomeView.swift

```swift
import SwiftUI

struct HomeView: View {
    @State private var checksCount = 0

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    headerSection

                    // Main Action Card
                    mainActionCard

                    // Stats
                    statsSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .withAegisBackground(showWatermark: true)
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.aegisGoldMid.opacity(0.1))
                    .frame(width: 90, height: 90)
                Circle()
                    .fill(Color.aegisGoldMid.opacity(0.15))
                    .frame(width: 70, height: 70)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(LinearGradient.aegisGoldGradient)
            }
            Text("Auntentic")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.aegisWhite)
            Text("AI-Powered Sneaker Authentication")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.aegisGray)
        }
        .padding(.top, 20)
    }

    private var mainActionCard: some View {
        AegisCard {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.aegisGoldMid.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.aegisGoldMid)
                }
                VStack(spacing: 8) {
                    Text("Start Authentication")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)
                    Text("Take 6 photos to verify your sneakers")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                }
                AegisPrimaryButton(title: "Take Photos", icon: "camera.fill") {
                    // Navigate to photo capture
                }
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("QUICK STATS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.aegisGoldMid)
                .tracking(1.2)
            HStack(spacing: 16) {
                AegisStatCard(icon: "clock.arrow.circlepath", value: "\(checksCount)", label: "History")
                AegisStatCard(icon: "star.fill", value: "1", label: "Free Check")
            }
        }
    }
}
```

---

## FILE 3: AuthView.swift

```swift
import SwiftUI

struct AuthView: View {
    @State private var isAppeared = false

    var body: some View {
        ZStack {
            LinearGradient.aegisNavyGradient.ignoresSafeArea()

            // Shield watermark
            GeometryReader { geo in
                Image(systemName: "shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.aegisGoldMid)
                    .opacity(0.03)
                    .frame(width: geo.size.width * 0.8)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.35)
            }

            VStack(spacing: 0) {
                Spacer()
                logoSection
                Spacer()
                authButtonsSection
                Spacer()
                disclaimerSection
            }
            .padding(.horizontal, 32)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isAppeared = true
            }
        }
    }

    private var logoSection: some View {
        VStack(spacing: 24) {
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(LinearGradient.aegisGoldGradient, lineWidth: 1.5)
                        .frame(width: CGFloat(140 + index * 30), height: CGFloat(140 + index * 30))
                        .opacity(0.15 - Double(index) * 0.04)
                }
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.aegisNavyLight, Color.aegisNavy],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .overlay(Circle().stroke(LinearGradient.aegisGoldGradient, lineWidth: 2))
                    .shadow(color: Color.aegisGoldMid.opacity(0.3), radius: 20, y: 8)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(LinearGradient.aegisGoldGradient)
            }
            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
                Text("CheckKicks")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)
                Text("AI-Powered Sneaker Authentication")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
            }
        }
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : -30)
    }

    private var authButtonsSection: some View {
        VStack(spacing: 16) {
            AegisPrimaryButton(title: "Sign in with Apple", icon: "apple.logo") {
                // Handle Apple sign in
            }
            AegisSecondaryButton(title: "Sign in with Email", icon: "envelope.fill") {
                // Handle email sign in
            }
        }
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 30)
    }

    private var disclaimerSection: some View {
        Text("By continuing, you agree to our Terms of Service and Privacy Policy")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.aegisMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
    }
}
```

---

## FILE 4: ResultsView.swift

```swift
import SwiftUI

struct ResultsView: View {
    let verdict: String // "authentic", "fake", "inconclusive"
    let confidence: Int
    let observations: [String]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Confidence Ring
                AegisResultBadge(verdict: verdict, confidence: confidence)
                    .padding(.top, 20)

                // Disclaimer
                disclaimerSection

                // Observations
                observationsSection

                Spacer(minLength: 20)

                // Action Buttons
                actionButtons
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .withAegisBackground()
    }

    private var disclaimerSection: some View {
        AegisCard(showGoldBorder: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.aegisWarning)
                    Text("Disclaimer")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aegisWarning)
                }
                Text("This analysis is for informational purposes only. We recommend professional verification for high-value items.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.aegisGray)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.aegisWarning.opacity(0.4), lineWidth: 1)
        )
    }

    private var observationsSection: some View {
        AegisCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI Observations")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.aegisWhite)
                ForEach(observations, id: \.self) { observation in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(verdictColor)
                        Text(observation)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.aegisGray)
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            AegisPrimaryButton(title: "New Check", icon: "camera.fill") {
                // Start new check
            }
            Button(action: { /* Go home */ }) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                    Text("Done")
                }
                .foregroundStyle(Color.aegisGoldMid)
            }
        }
    }

    private var verdictColor: Color {
        switch verdict {
        case "authentic": return .aegisSuccess
        case "fake": return .aegisError
        default: return .aegisWarning
        }
    }
}

struct AegisResultBadge: View {
    let verdict: String
    let confidence: Int
    @State private var confidenceProgress: Double = 0

    var verdictColor: Color {
        switch verdict {
        case "authentic": return .aegisSuccess
        case "fake": return .aegisError
        default: return .aegisWarning
        }
    }

    var verdictIcon: String {
        switch verdict {
        case "authentic": return "checkmark.shield.fill"
        case "fake": return "xmark.shield.fill"
        default: return "questionmark.circle.fill"
        }
    }

    var verdictText: String {
        switch verdict {
        case "authentic": return "Likely Authentic"
        case "fake": return "Likely Fake"
        default: return "Inconclusive"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.aegisNavyElevated, lineWidth: 12)
                    .frame(width: 180, height: 180)
                Circle()
                    .trim(from: 0, to: confidenceProgress)
                    .stroke(verdictColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 8) {
                    Image(systemName: verdictIcon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(verdictColor)
                    Text("\(Int(confidenceProgress * 100))%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.aegisWhite)
                    Text("Confidence")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.aegisGray)
                }
            }
            Text(verdictText)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(verdictColor)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                confidenceProgress = Double(confidence) / 100.0
            }
        }
    }
}
```

---

## FILE 5: PhotoCaptureStepView.swift (NEEDS AEGIS UPDATE)

**Current Design Issues:**
- Uses purple gradient instead of navy
- White buttons instead of gold
- No gold accents

**Suggested Updates:**
```swift
// Replace background gradient
LinearGradient.aegisNavyGradient.ignoresSafeArea()

// Replace "Take Photo" button
AegisPrimaryButton(title: "Take Photo", icon: "camera.fill") {
    showImagePicker = true
}

// Replace "Import from Gallery" button
AegisSecondaryButton(title: "Import from Gallery", icon: "photo.fill") {
    showGalleryPicker = true
}

// Update tip card
.background(Color.aegisNavyLight)
.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1))
```

---

## FILE 6: PhotoReviewView.swift (NEEDS AEGIS UPDATE)

**Current Design Issues:**
- System gray background
- Blue action button
- No gold styling

**Suggested Updates:**
```swift
// Replace background
.withAegisBackground()

// Replace "Authenticate Sneakers" button
AegisPrimaryButton(title: "Authenticate Sneakers", icon: "sparkles") {
    handleContinue()
}

// Update photo cards
.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.aegisGoldMid.opacity(0.2), lineWidth: 1))

// Update progress bar colors
foregroundGradient: [.aegisGoldLight, .aegisGoldMid]
```

---

## FILE 7: HistoryView.swift (PARTIAL AEGIS)

**Already Updated:**
- Verdict colors use Aegis semantic colors

**Still Needs:**
- Navy background
- Gold-bordered list items
- Empty state with gold accents

---

**End of Code Export**
