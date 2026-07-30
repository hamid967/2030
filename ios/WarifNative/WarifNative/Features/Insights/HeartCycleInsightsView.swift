import SwiftUI
import Charts

/// Optional Health trend overlays (resting heart rate, sleep) shown beside
/// cycle logs. Correlation is labelled as such — never causation or diagnosis.
struct HeartCycleInsightsView: View {
    @Environment(AppEnvironment.self) private var environment

    @State private var summaries: [DailyHealthSummary] = []
    @State private var loaded = false

    private let metrics: Set<HealthMetric> = [.heartRate, .restingHeartRate, .heartRateVariability, .sleep]

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
                            Text("متوسط النبض ونبض الراحة").font(.headline)
                            Chart(summaries) { summary in
                                if let heart = summary.averageHeartRate {
                                    LineMark(
                                        x: .value("اليوم", summary.day),
                                        y: .value("متوسط النبض", heart),
                                        series: .value("المؤشر", "متوسط النبض")
                                    )
                                    .foregroundStyle(WarifBrand.berry.opacity(0.55))
                                }
                                if let rhr = summary.restingHeartRate {
                                    LineMark(
                                        x: .value("اليوم", summary.day),
                                        y: .value("نبض الراحة", rhr),
                                        series: .value("المؤشر", "نبض الراحة")
                                    )
                                    .foregroundStyle(WarifBrand.berry)
                                }
                            }
                            .frame(height: 200)
                        }
                    }
                    WarifCard {
                        Text("تُستخدم بيانات القلب والنوم كسياق عام فقط. هذه علاقة وليست سبباً، ولا تُعتبر تشخيصاً أو مراقبة طوارئ. المصدر: تطبيق صحتي، وتُحلل العينات على جهازك.")
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
