import SwiftUI

/// Renders ROG-inspired neon rings around the closed notch surface.
///
/// The effect is deliberately additive and stroke-only: it surrounds the
/// island without covering the notch's interactive content.
struct ROGNotchLightingEffect<ShapeType: Shape>: View {
    let shape: ShapeType
    let mode: ROGNotchLightingMode

    var body: some View {
        TimelineView(.animation) { context in
            ROGNotchLightingLayer(
                shape: shape,
                mode: mode,
                date: context.date
            )
        }
    }
}

private struct ROGNotchLightingLayer<ShapeType: Shape>: View {
    let shape: ShapeType
    let mode: ROGNotchLightingMode
    let date: Date

    private var colors: [Color] { [
        Color(red: 1.00, green: 0.18, blue: 0.47),
        Color(red: 0.55, green: 0.16, blue: 1.00),
        Color(red: 0.13, green: 0.83, blue: 0.93),
        Color(red: 0.13, green: 0.39, blue: 1.00),
    ] }

    private var elapsed: TimeInterval {
        max(0, date.timeIntervalSinceReferenceDate)
    }

    /// Mode-specific envelope. `breathing` is the calm default; `pulse`
    /// decays quickly to suggest a gaming notification heartbeat.
    private var intensity: Double {
        switch mode {
        case .breathing:
            return 0.42 + 0.58 * (0.5 - 0.5 * cos((2 * .pi * elapsed) / 2.8))
        case .spectrumFlow:
            return 0.88
        case .pulse:
            let cycle = elapsed.truncatingRemainder(dividingBy: 1.5)
            let envelope = exp(-5 * cycle)
            return 0.52 + 0.48 * envelope
        case .staticGlow:
            return 0.78
        }
    }

    /// Only modes intended to move rotate the spectrum. Breathing keeps the
    /// same hue while the whole ring changes brightness.
    private var hueRotationDegrees: Double {
        switch mode {
        case .breathing, .staticGlow:
            0
        case .spectrumFlow:
            (elapsed * 70).truncatingRemainder(dividingBy: 360)
        case .pulse:
            (elapsed * 45).truncatingRemainder(dividingBy: 360)
        }
    }

    private var spectrum: AngularGradient {
        let colors = colors
        return AngularGradient(
            colors: colors + [colors[0]],
            center: .center,
            angle: .degrees(0)
        )
    }

    var body: some View {
        ZStack {
            // Broad atmospheric bloom under the crisper neon rings.
            shape
                .stroke(spectrum, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .padding(-1)
                .blur(radius: 7)
                .opacity(0.52 * intensity)

            // Main neon edge.
            shape
                .stroke(spectrum, style: StrokeStyle(lineWidth: 2.7, lineCap: .round, lineJoin: .round))
                .blur(radius: 0.5)
                .opacity(intensity)

            // Two additional, softer rings produce the concentric look.
            shape
                .stroke(spectrum, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .padding(-4)
                .opacity(0.58 * intensity)

            shape
                .stroke(spectrum, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                .padding(-7)
                .opacity(0.32 * intensity)
        }
        .hueRotation(.degrees(hueRotationDegrees))
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }
}
