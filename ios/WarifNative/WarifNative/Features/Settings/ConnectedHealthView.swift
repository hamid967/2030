import SwiftUI

struct ConnectedHealthView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var available: Bool?
    @State private var status: String?

    private let metrics: Set<HealthMetric> = [
        .restingHeartRate, .heartRateVariability, .sleep, .steps, .activeEnergy,
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                WarifCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("اربطي بيانات الصحة باختيارك").font(.headline)
                        Text("يمكن لوريف قراءة ملخصات النبض والنوم والنشاط لعرض أنماط عامة بجانب تسجيلات دورتك. الربط اختياري ويمكن إيقافه من إعدادات iPhone في أي وقت.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }

                if available == false {
                    WarifCard { Text("بيانات الصحة غير متاحة على هذا الجهاز.").foregroundStyle(.secondary) }
                }
                if let status {
                    WarifCard { Text(status).font(.footnote).foregroundStyle(.secondary) }
                }

                Button("ربط تطبيق صحتي") { Task { await connect() } }
                    .warifPrimaryButton()
                Text("مو الحين")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("بيانات الصحة")
        .task { available = await environment.health.isAvailable() }
    }

    private func connect() async {
        do {
            try await environment.health.requestReadAuthorization(for: metrics)
            status = "تم إرسال طلب الإذن. تُحلل العينات على جهازك ولا تُرفع القراءات الخام."
        } catch {
            status = "تعذّر إكمال الطلب. يمكنك المتابعة بدون ربط بيانات الصحة."
        }
    }
}

#Preview {
    NavigationStack { ConnectedHealthView() }
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
