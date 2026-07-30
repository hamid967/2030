import SwiftUI

struct WellnessProfileView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var profile = WellnessProfile.starter
    @State private var isSaving = false
    @State private var saved = false

    var body: some View {
        Form {
            Section("ما الذي يهمك الآن؟") {
                ForEach(WellnessGoal.allCases) { goal in
                    Toggle(goal.titleAr, isOn: binding(for: goal))
                }
            }
            Section("إشارات تودين متابعتها") {
                ForEach(BodySignal.allCases) { signal in
                    Toggle(signal.titleAr, isOn: signalBinding(for: signal))
                }
            }
            Section("الخصوصية والتجربة") {
                Toggle("الوضع الحساس", isOn: $profile.sensitiveModeEnabled)
                Toggle("إظهار المجتمع", isOn: $profile.communityEnabled)
                Text("الوضع الحساس يضيف تذكيرات خصوصية إلى رؤاك. خياراتك تبقى مشفرة على هذا الجهاز.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section {
                Button(isSaving ? "جارٍ الحفظ…" : "حفظ التفضيلات") { Task { await save() } }
                    .disabled(isSaving)
                if saved {
                    Label("تم حفظ التخصيص", systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(WarifBrand.berry)
                }
            }
        }
        .navigationTitle("تخصيص العافية")
        .task { profile = await environment.wellnessProfile.load() }
    }

    private func binding(for goal: WellnessGoal) -> Binding<Bool> {
        Binding(
            get: { profile.goals.contains(goal) },
            set: { enabled in update(&profile.goals, item: goal, enabled: enabled) }
        )
    }

    private func signalBinding(for signal: BodySignal) -> Binding<Bool> {
        Binding(
            get: { profile.preferredSignals.contains(signal) },
            set: { enabled in update(&profile.preferredSignals, item: signal, enabled: enabled) }
        )
    }

    private func update<Item: Hashable>(_ values: inout Set<Item>, item: Item, enabled: Bool) {
        if enabled { values.insert(item) } else { values.remove(item) }
        saved = false
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await environment.wellnessProfile.save(profile)
            saved = true
        } catch {
            saved = false
        }
    }
}

private extension WellnessGoal {
    var titleAr: String {
        switch self {
        case .understandCycle: "فهم نمط الدورة"
        case .reducePain: "التعامل مع الألم"
        case .improveEnergy: "تحسين الطاقة"
        case .improveSleep: "تحسين النوم"
        case .supportMood: "دعم المزاج"
        case .tryingToConceive: "الاستعداد للحمل"
        case .pregnancySupport: "دعم الحمل"
        case .prepareDoctorVisit: "التحضير لزيارة مختصة"
        }
    }
}

private extension BodySignal {
    var titleAr: String {
        switch self {
        case .cramps: "تقلصات"
        case .headache: "صداع"
        case .bloating: "انتفاخ"
        case .breastTenderness: "حساسية الثدي"
        case .cravings: "رغبات غذائية"
        case .acne: "حبوب البشرة"
        case .backPain: "ألم الظهر"
        case .nausea: "غثيان"
        case .calm: "هدوء"
        case .anxious: "قلق"
        case .energized: "طاقة مرتفعة"
        case .fatigued: "إرهاق"
        }
    }
}
