import SwiftUI

/// A transparent, on-device intelligence surface. It turns existing entries
/// into practical next steps without making clinical claims or sending data away.
struct SmartCareView: View {
    @Environment(AppEnvironment.self) private var environment

    @State private var insight: DailyInsight?
    @State private var phase: CyclePhase?
    @State private var cycleDay = 0
    @State private var dataPoints = 0
    @State private var isLoading = true

    private var theme: RegionTheme { environment.regionTheme.activeTheme }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("يجري تجهيز قراءة اليوم…")
                        .padding(.vertical, 40)
                } else if let insight, let phase {
                    statusCard(insight: insight, phase: phase)
                    focusCard(insight: insight)
                    planCard(insight: insight)
                    transparencyCard(insight: insight)
                    safetyNote
                } else {
                    emptyState
                }
            }
            .padding()
        }
        .background(RegionalBackdrop(theme: theme))
        .navigationTitle("ذكاء وريف")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func statusCard(insight: DailyInsight, phase: CyclePhase) -> some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("قراءة اليوم")
                            .font(.headline)
                        Text("اليوم \(cycleDay) · \(WarifCopy.stateName(phase))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: symbol(for: insight.tone))
                        .font(.title2)
                        .foregroundStyle(theme.primary)
                }
                Text(insight.titleAr)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(WarifBrand.textPlum)
                Text(insight.bodyAr)
                    .foregroundStyle(.secondary)
                Divider()
                HStack {
                    Label("\(dataPoints) نقاط بيانات", systemImage: "chart.bar.doc.horizontal")
                    Spacer()
                    Label(dataQuality, systemImage: "checkmark.seal")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func focusCard(insight: DailyInsight) -> some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("أولوية اليوم", systemImage: "target")
                    .font(.headline)
                    .foregroundStyle(theme.primary)
                if let action = insight.actions.first {
                    Text(action.titleAr).font(.title3.weight(.semibold))
                    Text(action.bodyAr).foregroundStyle(.secondary)
                }
                NavigationLink("تسجيل تفاصيل اليوم") { CheckInView() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primary)
                    .padding(.top, 2)
            }
        }
    }

    private func planCard(insight: DailyInsight) -> some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("خطة عناية قصيرة").font(.headline)
                ForEach(Array(insight.actions.prefix(3).enumerated()), id: \.element.id) { index, action in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(theme.primary)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(action.titleAr).font(.subheadline.weight(.semibold))
                            Text(action.bodyAr).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func transparencyCard(insight: DailyInsight) -> some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("كيف تكوّنت القراءة؟", systemImage: "eye")
                    .font(.headline)
                ForEach(insight.evidenceAr, id: \.self) { evidence in
                    Label(evidence, systemImage: "circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text("تُعالج هذه البيانات على جهازك. لا تستخدم وريف أي قراءة لاتخاذ قرار طبي نيابةً عنك.")
                    .font(.footnote)
                    .foregroundStyle(theme.primary)
                    .padding(.top, 4)
            }
        }
    }

    private var emptyState: some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("ابدئي بتسجيل بسيط", systemImage: "sparkles")
                    .font(.headline)
                Text("أضيفي تاريخ دورة وتسجيلًا يوميًا ليبدأ ذكاء وريف بتقديم قراءة أكثر فائدة.")
                    .foregroundStyle(.secondary)
                NavigationLink("سجلي يومك") { CheckInView() }
                    .foregroundStyle(theme.primary)
            }
        }
    }

    private var safetyNote: some View {
        Text("هذه قراءة تثقيفية وليست تشخيصًا أو وسيلة لمنع الحمل. عند ألم شديد، تغير مفاجئ، أو حالة طارئة، تواصلي مع مختصة أو خدمات الطوارئ.")
            .font(.footnote)
            .foregroundStyle(WarifBrand.berryStrong)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dataQuality: String {
        switch dataPoints {
        case 0...3: "بداية التعلم"
        case 4...9: "قراءة أولية"
        default: "قراءة أغنى"
        }
    }

    private func load() async {
        defer { isLoading = false }
        guard let profile = await environment.cycle.getProfile() else { return }

        let today = Date()
        let day = CycleEngine.cycleDay(
            lastPeriodStart: profile.lastPeriodStart,
            cycleLength: profile.cycleLength,
            today: today
        )
        let currentPhase = CycleEngine.phase(
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
        let prediction = CycleEngine.predict(periodStarts: profile.periodStarts, today: today)

        cycleDay = day
        phase = currentPhase
        dataPoints = profile.periodStarts.count + checkIns.count + health.count
        insight = DailyInsightEngine.generate(
            DailyInsightInput(
                cyclePhase: currentPhase,
                cycleDay: day,
                prediction: prediction,
                checkIns: checkIns,
                healthSummaries: health,
                region: environment.regionTheme.preference?.region,
                wellnessProfile: await environment.wellnessProfile.load()
            )
        )
    }

    private func symbol(for tone: InsightTone) -> String {
        switch tone {
        case .calm: "leaf.fill"
        case .encouraging: "sparkles"
        case .caution: "exclamationmark.shield.fill"
        case .privacy: "lock.shield.fill"
        }
    }
}

#Preview {
    NavigationStack { SmartCareView() }
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
