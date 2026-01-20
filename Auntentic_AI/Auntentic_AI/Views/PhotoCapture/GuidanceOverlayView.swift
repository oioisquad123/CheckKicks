//
//  GuidanceOverlayView.swift
//  Auntentic_AI
//
//  Created on December 26, 2025.
//

import SwiftUI

/// Semi-transparent overlay showing guidance for photo capture
struct GuidanceOverlayView: View {
    let step: PhotoCaptureStep

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Guidance outline/frame
            VStack(spacing: 20) {
                // Icon representing what to capture
                Image(systemName: iconName)
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 10)

                // Guidance frame
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                    .foregroundStyle(.white)
                    .frame(width: frameWidth, height: frameHeight)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                    .overlay {
                        Text(step.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .offset(y: -frameHeight / 2 - 40)
                    }

                // Hint text
                VStack(spacing: 12) {
                    Text("Align the \(step.title.lowercased()) within the frame")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.5), radius: 5)

                    // Tap to dismiss hint
                    Text("Tap anywhere to see detailed photo tips")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.5), radius: 5)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var iconName: String {
        return step.silhouetteIcon
    }

    private var frameWidth: CGFloat {
        return 300
    }

    private var frameHeight: CGFloat {
        return 300
    }
}

#Preview {
    GuidanceOverlayView(step: .outerSide)
}

#Preview("Inner Side") {
    GuidanceOverlayView(step: .innerSide)
}

#Preview("Size Tag") {
    GuidanceOverlayView(step: .sizeTag)
}

#Preview("Sole View") {
    GuidanceOverlayView(step: .soleView)
}
