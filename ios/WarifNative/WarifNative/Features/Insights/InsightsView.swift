import SwiftUI

struct InsightsView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var prediction: CyclePrediction?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WarifCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("الرؤى").font(.headline)
                            if let prediction {
                                Text("وسيط طول الدورة: \(prediction.medianCycleLength.map(String.init) ?? "—") يوم")
                                Text("عدد الدورات المسجّلة: \(prediction.cyclesUsed)")
                                Text("مستوى الثقة: \(WarifCopy.confidence(prediction.confidence))")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("جارٍ الحساب…").foregroundStyle(.secondary)
                            }
                        }
                    }
                    WarifCard {
                        Text("لاحظنا نمطاً في تسجيلاتك — هذه علاقة وليست سبباً، ولا تُعتبر تشخيصاً لأي حالة.")
                            .font(.footnote)
                            .foregroundStyle(WarifBrand.berryStrong)
                    }
                }
                .padding()
            }
            .navigationTitle("الرؤى")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            if let p = await environment.cycle.getProfile() {
                prediction = CycleEngine.predict(periodStarts: p.periodStarts, today: Date())
            }
        }
    }
}

#Preview {
    InsightsView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
