import SwiftUI

struct TodayView: View {
    @Environment(AppEnvironment.self) private var environment

    @State private var profile: CycleProfile?
    @State private var prediction: CyclePrediction?

    private var theme: RegionTheme { environment.regionTheme.activeTheme }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    if let profile {
                        ringSection(profile)
                        estimateSection
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
            prediction = CycleEngine.predict(
                periodStarts: loaded.periodStarts, today: Date()
            )
        }
    }
}

#Preview {
    TodayView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
