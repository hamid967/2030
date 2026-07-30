import SwiftUI

/// Original Warif cycle ring: an outer track plus a themed progress arc, with
/// the day number and phase label in the center. The label is always present
/// so meaning is never conveyed by color alone.
struct CyclePhaseRing: View {
    let cycleDay: Int
    let cycleLength: Int
    let phaseLabel: String
    var color: Color = WarifBrand.berry

    private var progress: Double {
        guard cycleLength > 0 else { return 0 }
        return min(Double(cycleDay) / Double(cycleLength), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "#EADDE2"), lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text("\(cycleDay)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(WarifBrand.textPlum)
                Text(phaseLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 200, height: 200)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("اليوم \(cycleDay) من دورتك، \(phaseLabel)")
    }
}
