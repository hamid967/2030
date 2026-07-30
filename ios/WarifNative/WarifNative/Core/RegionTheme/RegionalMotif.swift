import SwiftUI

/// A light, abstract decorative motif drawn with Canvas. Purely decorative and
/// hidden from accessibility; it never conveys a medical state.
struct RegionalMotif: View {
    let theme: RegionTheme

    var body: some View {
        Canvas { context, size in
            let accent = theme.accent.opacity(0.18)
            switch theme.motif {
            case .waves, .terraceCurves:
                for i in 0..<3 {
                    var path = Path()
                    let y = size.height * (0.55 + Double(i) * 0.12)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addCurve(
                        to: CGPoint(x: size.width, y: y - 12),
                        control1: CGPoint(x: size.width * 0.3, y: y - 30),
                        control2: CGPoint(x: size.width * 0.7, y: y + 20)
                    )
                    context.stroke(path, with: .color(accent), lineWidth: 10)
                }
            case .mountainCurves, .twinMountains, .canyonLayers, .mistLayers:
                for i in 0..<3 {
                    var path = Path()
                    let base = size.height * (0.5 + Double(i) * 0.14)
                    path.move(to: CGPoint(x: 0, y: base))
                    path.addLine(to: CGPoint(x: size.width * 0.5, y: base - 60))
                    path.addLine(to: CGPoint(x: size.width, y: base))
                    context.stroke(path, with: .color(accent), lineWidth: 8)
                }
            case .horizonStars:
                for _ in 0..<14 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...(size.height * 0.5))
                    let rect = CGRect(x: x, y: y, width: 3, height: 3)
                    context.fill(Path(ellipseIn: rect), with: .color(accent))
                }
            default:
                for i in 0..<4 {
                    let inset = Double(i) * 22
                    let rect = CGRect(
                        x: inset, y: size.height * 0.4 + inset,
                        width: max(0, size.width - inset * 2),
                        height: 24
                    )
                    context.stroke(
                        Path(roundedRect: rect, cornerRadius: 8),
                        with: .color(accent), lineWidth: 4
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
