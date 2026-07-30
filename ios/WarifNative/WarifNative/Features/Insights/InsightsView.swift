import SwiftUI

struct InsightsView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var prediction: CyclePrediction?
    @State private var dailyInsight: DailyInsight?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let dailyInsight {
                        insightSummary(dailyInsight)
                    }
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
                    if let dailyInsight {
                        actionsSection(dailyInsight)
                        evidenceSection(dailyInsight)
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
                let nextPrediction = CycleEngine.predict(periodStarts: p.periodStarts, today: Date())
                prediction = nextPrediction
                dailyInsight = await buildDailyInsight(profile: p, prediction: nextPrediction)
            }
        }
    }

    private func insightSummary(_ insight: DailyInsight) -> some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.titleAr)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(WarifBrand.berryStrong)
                Text(insight.bodyAr)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func actionsSection(_ insight: DailyInsight) -> some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("إضافات مقترحة ليومك").font(.headline)
                ForEach(insight.actions) { action in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: symbol(for: action.kind))
                            .foregroundStyle(WarifBrand.berry)
                            .frame(width: 22)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(action.titleAr).font(.subheadline.weight(.semibold))
                            Text(action.bodyAr).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func evidenceSection(_ insight: DailyInsight) -> some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("لماذا ظهرت هذه الرؤية؟").font(.headline)
                ForEach(insight.evidenceAr, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text(insight.medicalDisclaimerAr)
                    .font(.footnote)
                    .foregroundStyle(WarifBrand.berryStrong)
            }
        }
    }

    private func buildDailyInsight(
        profile: CycleProfile,
        prediction: CyclePrediction
    ) async -> DailyInsight {
        let today = Date()
        let day = CycleEngine.cycleDay(
            lastPeriodStart: profile.lastPeriodStart,
            cycleLength: profile.cycleLength,
            today: today
        )
        let phase = CycleEngine.phase(
            cycleDay: day,
            periodLength: profile.periodLength,
            cycleLength: profile.cycleLength
        )
        let checkIns = await environment.checkIn.recent(days: 14, endingOn: today)
        let health = (try? await environment.health.dailySummaries(
            metrics: [.heartRate, .restingHeartRate, .heartRateVariability, .sleep, .steps],
            interval: DateInterval(start: WarifCalendar.adding(-14, to: today), end: today),
            calendar: WarifCalendar.riyadh
        )) ?? []

        return DailyInsightEngine.generate(
            DailyInsightInput(
                cyclePhase: phase,
                cycleDay: day,
                prediction: prediction,
                checkIns: checkIns,
                healthSummaries: health,
                region: environment.regionTheme.preference?.region,
                wellnessProfile: await environment.wellnessProfile.load()
            )
        )
    }

    private func symbol(for kind: CareActionKind) -> String {
        switch kind {
        case .log: "square.and.pencil"
        case .rest: "bed.double"
        case .movement: "figure.walk"
        case .hydration: "drop"
        case .sleep: "moon"
        case .nutrition: "fork.knife"
        case .breathing: "wind"
        case .doctor: "cross.case"
        case .privacy: "lock.shield"
        case .community: "person.2"
        }
    }
}

#Preview {
    InsightsView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
