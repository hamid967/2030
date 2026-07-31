import SwiftUI

struct TodayView: View {
    @Environment(AppEnvironment.self) private var environment

    @State private var profile: CycleProfile?
    @State private var prediction: CyclePrediction?
    @State private var dailyInsight: DailyInsight?

    private var theme: RegionTheme { environment.regionTheme.activeTheme }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    if let profile {
                        ringSection(profile)
                        estimateSection
                        dailyInsightSection
                        smartCareCTA
                        checkInCTA
                        trustedContentCard
                    } else {
                        WarifCard { Text("جارٍ تحضير يومك…").foregroundStyle(.secondary) }
                    }
                    disclaimer
                }
                .padding()
            }
            .background(RegionalBackdrop(theme: theme))
            .navigationTitle("يومي")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("الإعدادات")
                }
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private var dailyInsightSection: some View {
        if let dailyInsight {
            WarifCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label(dailyInsight.titleAr, systemImage: icon(for: dailyInsight.tone))
                        .font(.headline)
                        .foregroundStyle(color(for: dailyInsight.tone))
                    Text(dailyInsight.bodyAr)
                        .foregroundStyle(.secondary)
                    if let first = dailyInsight.actions.first {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text(first.titleAr)
                                .font(.subheadline.weight(.semibold))
                            Text(first.bodyAr)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("صباح الخير، كيف تحسين اليوم؟")
                .font(.title3.weight(.semibold))
                .foregroundStyle(WarifBrand.textPlum)
            if let region = environment.regionTheme.preference?.region {
                Text(region.displayName())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func ringSection(_ profile: CycleProfile) -> some View {
        let day = CycleEngine.cycleDay(
            lastPeriodStart: profile.lastPeriodStart,
            cycleLength: profile.cycleLength, today: Date()
        )
        let phase = CycleEngine.phase(
            cycleDay: day, periodLength: profile.periodLength,
            cycleLength: profile.cycleLength
        )
        return VStack(spacing: 12) {
            CyclePhaseRing(
                cycleDay: day, cycleLength: profile.cycleLength,
                phaseLabel: WarifCopy.stateName(phase), color: theme.primary
            )
            if let prediction {
                Text("\(WarifCopy.confidence(prediction.confidence)) · \(prediction.cyclesUsed) دورات مسجّلة")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var estimateSection: some View {
        if let prediction, let earliest = prediction.earliestDate,
           let latest = prediction.latestDate {
            WarifCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("الدورة القادمة المتوقعة").font(.headline)
                    Text("بين \(WarifFormat.mediumDate(earliest)) و\(WarifFormat.mediumDate(latest))")
                        .foregroundStyle(.secondary)
                    Text("هذه تقديرات وقد يتغير الموعد حسب نمط جسمك.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
    }

    private var checkInCTA: some View {
        NavigationLink {
            CheckInView()
        } label: {
            Text("سجّلي يومك")
        }
        .warifPrimaryButton()
    }

    private var smartCareCTA: some View {
        NavigationLink {
            SmartCareView()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                VStack(alignment: .leading, spacing: 2) {
                    Text("ذكاء وريف")
                        .font(.headline)
                    Text("خطة يومية مبنية على تسجيلاتك")
                        .font(.footnote)
                }
                Spacer()
                Image(systemName: "chevron.left")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(.white)
        }
        .warifPrimaryButton()
    }

    private var trustedContentCard: some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("معلومة موثوقة").font(.headline)
                Text("سجّلي اللي تحسين فيه، حتى لو ما كان يومك مثالي.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var disclaimer: some View {
        WarifCard {
            Text("وريف أداة متابعة وتثقيف، وليست تشخيصاً أو وسيلة لمنع الحمل. هذه ملاحظات من تسجيلاتك وليست تشخيصاً.")
                .font(.footnote)
                .foregroundStyle(WarifBrand.berryStrong)
        }
    }

    private func load() async {
        let loaded = await environment.cycle.getProfile()
        profile = loaded
        if let loaded {
            let nextPrediction = CycleEngine.predict(
                periodStarts: loaded.periodStarts, today: Date()
            )
            prediction = nextPrediction
            dailyInsight = await buildDailyInsight(profile: loaded, prediction: nextPrediction)
        }
    }

    private func buildDailyInsight(
        profile: CycleProfile,
        prediction: CyclePrediction
    ) async -> DailyInsight {
        let today = Date()
        let cycleDay = CycleEngine.cycleDay(
            lastPeriodStart: profile.lastPeriodStart,
            cycleLength: profile.cycleLength,
            today: today
        )
        let phase = CycleEngine.phase(
            cycleDay: cycleDay,
            periodLength: profile.periodLength,
            cycleLength: profile.cycleLength
        )
        let checkIns = await environment.checkIn.recent(days: 7, endingOn: today)
        let healthSummaries = (try? await environment.health.dailySummaries(
            metrics: [.heartRate, .restingHeartRate, .heartRateVariability, .sleep, .steps],
            interval: DateInterval(
                start: WarifCalendar.adding(-7, to: today),
                end: today
            ),
            calendar: WarifCalendar.riyadh
        )) ?? []

        return DailyInsightEngine.generate(
            DailyInsightInput(
                cyclePhase: phase,
                cycleDay: cycleDay,
                prediction: prediction,
                checkIns: checkIns,
                healthSummaries: healthSummaries,
                region: environment.regionTheme.preference?.region,
                wellnessProfile: await environment.wellnessProfile.load()
            )
        )
    }

    private func icon(for tone: InsightTone) -> String {
        switch tone {
        case .calm: "leaf"
        case .encouraging: "sparkles"
        case .caution: "exclamationmark.triangle"
        case .privacy: "lock.shield"
        }
    }

    private func color(for tone: InsightTone) -> Color {
        switch tone {
        case .calm, .privacy: WarifBrand.berryStrong
        case .encouraging: WarifBrand.berry
        case .caution: Color.orange
        }
    }
}

#Preview {
    TodayView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
