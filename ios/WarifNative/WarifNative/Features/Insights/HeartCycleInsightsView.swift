import SwiftUI
import Charts

/// Optional Health trend overlays (resting heart rate, sleep) shown beside
/// cycle logs. Correlation is labelled as such — never causation or diagnosis.
struct HeartCycleInsightsView: View {
    @Environment(AppEnvironment.self) private var environment

    @State private var summaries: [DailyHealthSummary] = []
    @State private var loaded = false

    private let metrics: Set<HealthMetric> = [.restingHeartRate, .sleep]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !loaded {
                    ProgressView().padding()
                } else if summaries.isEmpty {
                    WarifCard {
                        Text("لا توجد بيانات صحية بعد. اربطي تطبيق صحتي من الإعدادات لعرض الأنماط.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Charts sit on a solid surface, never a textured backdrop.
                    WarifCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("نبض الراحة (آخر أيام)").font(.headline)
                            Chart(summaries) { summary in
                                if let rhr = summary.restingHeartRate {
                                    LineMark(
                                        x: .value("اليوم", summary.day),
                                        y: .value("نبض الراحة", rhr)
                                    )
                                    .foregroundStyle(WarifBrand.berry)
                                }
                            }
                            .frame(height: 200)
                        }
                    }
                    WarifCard {
                        Text("ظهر تزامن في تسجيلاتك — هذه علاقة وليست سبباً، ولا تُعتبر تشخيصاً. المصدر: تطبيق صحتي، تُحلل العينات على جهازك.")
                            .font(.footnote).foregroundStyle(WarifBrand.berryStrong)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("أنماط النبض والنوم")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        defer { loaded = true }
        guard await environment.health.isAvailable() else { return }
        let calendar = WarifCalendar.riyadh
        let end = Date()
        let start = WarifCalendar.adding(-14, to: end, calendar)
        summaries = (try? await environment.health.dailySummaries(
            metrics: metrics,
            interval: DateInterval(start: start, end: end),
            calendar: calendar
        )) ?? []
    }
}

#Preview {
    NavigationStack { HeartCycleInsightsView() }
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
