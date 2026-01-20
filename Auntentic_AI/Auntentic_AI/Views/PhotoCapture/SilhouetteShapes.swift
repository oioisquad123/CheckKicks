//
//  SilhouetteShapes.swift
//  Auntentic_AI
//
//  Shoe silhouette shapes for camera guidance overlay
//

import SwiftUI

// MARK: - Silhouette Overlay View

struct SilhouetteOverlayView: View {
    let step: PhotoCaptureStep
    var opacity: Double = 0.5  // Increased for stroke-only visibility

    var body: some View {
        Group {
            switch step {
            case .outerSide:
                OuterSideSilhouette()
            case .innerSide:
                InnerSideSilhouette()
            case .soleView:
                SoleSilhouette()
            case .heelDetail:
                HeelSilhouette()
            case .tongueLabel:
                LabelSilhouette()
            case .sizeTag:
                LabelSilhouette()
            }
        }
        .foregroundStyle(Color.white.opacity(opacity))
    }
}

// MARK: - Outer Side Silhouette (Shoe Profile Facing Left - OUTLINE ONLY)

struct OuterSideSilhouette: View {
    var body: some View {
        // Stroke only - no fill for transparency
        ShoeProfileShape()
            .stroke(
                Color.white,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 280, height: 160)
            .scaleEffect(x: -1, y: 1) // Mirror to face left
    }
}

struct ShoeProfileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Start at heel bottom
        path.move(to: CGPoint(x: w * 0.05, y: h * 0.85))

        // Heel curve up
        path.addQuadCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.35),
            control: CGPoint(x: w * 0.02, y: h * 0.6)
        )

        // Heel top to collar
        path.addQuadCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.15),
            control: CGPoint(x: w * 0.12, y: h * 0.2)
        )

        // Collar/ankle opening
        path.addQuadCurve(
            to: CGPoint(x: w * 0.45, y: h * 0.2),
            control: CGPoint(x: w * 0.35, y: h * 0.1)
        )

        // Tongue area
        path.addQuadCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.25),
            control: CGPoint(x: w * 0.5, y: h * 0.18)
        )

        // Upper to toe
        path.addQuadCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.45),
            control: CGPoint(x: w * 0.7, y: h * 0.28)
        )

        // Toe box curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.98, y: h * 0.65),
            control: CGPoint(x: w * 0.98, y: h * 0.5)
        )

        // Toe to sole front
        path.addQuadCurve(
            to: CGPoint(x: w * 0.9, y: h * 0.85),
            control: CGPoint(x: w * 0.98, y: h * 0.8)
        )

        // Sole (bottom)
        path.addLine(to: CGPoint(x: w * 0.05, y: h * 0.85))

        path.closeSubpath()
        return path
    }
}

// MARK: - Inner Side Silhouette (Shoe Profile Facing Right - OUTLINE ONLY)

struct InnerSideSilhouette: View {
    var body: some View {
        // Stroke only - no fill for transparency
        ShoeProfileShape()
            .stroke(
                Color.white,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 280, height: 160)
    }
}

// MARK: - Sole Silhouette (Bottom View - OUTLINE ONLY)

struct SoleSilhouette: View {
    var body: some View {
        // Stroke only - no fill for transparency
        SoleShape()
            .stroke(
                Color.white,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 140, height: 320)
    }
}

struct SoleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Start at heel center bottom
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.98))

        // Heel left curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.85),
            control: CGPoint(x: w * 0.2, y: h * 0.98)
        )

        // Left arch
        path.addQuadCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.55),
            control: CGPoint(x: w * 0.08, y: h * 0.7)
        )

        // Left side to ball of foot
        path.addQuadCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.3),
            control: CGPoint(x: w * 0.05, y: h * 0.42)
        )

        // Left toe area
        path.addQuadCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.08),
            control: CGPoint(x: w * 0.08, y: h * 0.15)
        )

        // Toe tip
        path.addQuadCurve(
            to: CGPoint(x: w * 0.75, y: h * 0.08),
            control: CGPoint(x: w * 0.5, y: h * 0.02)
        )

        // Right toe area
        path.addQuadCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.3),
            control: CGPoint(x: w * 0.92, y: h * 0.15)
        )

        // Right side from ball
        path.addQuadCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.55),
            control: CGPoint(x: w * 0.95, y: h * 0.42)
        )

        // Right arch
        path.addQuadCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.85),
            control: CGPoint(x: w * 0.92, y: h * 0.7)
        )

        // Heel right curve back to start
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.98),
            control: CGPoint(x: w * 0.8, y: h * 0.98)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Heel Silhouette (Back View - OUTLINE ONLY)

struct HeelSilhouette: View {
    var body: some View {
        // Stroke only - no fill for transparency
        HeelShape()
            .stroke(
                Color.white,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 160, height: 200)
            .rotationEffect(.degrees(180)) // Flip to match reference orientation
    }
}

struct HeelShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Start at bottom left
        path.move(to: CGPoint(x: w * 0.1, y: h * 0.95))

        // Left side up
        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.7))

        // Left heel counter curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.35),
            control: CGPoint(x: w * 0.08, y: h * 0.5)
        )

        // Left collar curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.3, y: h * 0.12),
            control: CGPoint(x: w * 0.18, y: h * 0.2)
        )

        // Top collar curve (ankle opening)
        path.addQuadCurve(
            to: CGPoint(x: w * 0.7, y: h * 0.12),
            control: CGPoint(x: w * 0.5, y: h * 0.05)
        )

        // Right collar curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.35),
            control: CGPoint(x: w * 0.82, y: h * 0.2)
        )

        // Right heel counter curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.9, y: h * 0.7),
            control: CGPoint(x: w * 0.92, y: h * 0.5)
        )

        // Right side down
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.95))

        // Bottom
        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.95))

        path.closeSubpath()
        return path
    }
}

// MARK: - Label/Tag Silhouette (Rectangle - OUTLINE ONLY)

struct LabelSilhouette: View {
    var body: some View {
        ZStack {
            // Outer rectangle - stroke only
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 200, height: 140)

            // Inner lines to suggest text - subtle strokes
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 120, height: 2)

                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 100, height: 2)

                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 80, height: 2)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            SilhouetteOverlayView(step: .outerSide)
            SilhouetteOverlayView(step: .soleView)
            SilhouetteOverlayView(step: .heelDetail)
        }
    }
}
