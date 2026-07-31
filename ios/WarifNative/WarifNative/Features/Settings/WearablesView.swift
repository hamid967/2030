import SwiftUI

struct WearablesView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var healthAvailable: Bool?
    @State private var syncToWatch = true
    @State private var statusMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                appleWatchCard
                healthBridgeCard
                compatibilityCard
                privacyNote
            }
            .padding()
        }
        .background(WarifBrand.ivory)
        .navigationTitle("الساعات والأجهزة")
        .task {
            healthAvailable = await environment.health.isAvailable()
            environment.wearables.start()
        }
    }

    private var appleWatchCard: some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Apple Watch", systemImage: "applewatch")
                        .font(.headline)
                    Spacer()
                    Text(environment.wearables.status.titleAr)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(statusColor)
                }
                Text("يعرض وريف على الساعة خطوة اليوم المقترحة، ويستفيد من ملخصات النوم والنشاط والنبض التي تمنحينها الإذن عبر Apple Health.")
                    .font(.subheadline)
                    .foregroundStyle(WarifBrand.mutedText)
                Toggle("مزامنة ملخص اليوم مع الساعة", isOn: $syncToWatch)
                    .onChange(of: syncToWatch) { _, enabled in
                        if enabled { syncToday() }
                    }
                Button("تحديث الساعة الآن") { syncToday() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WarifBrand.berry)
                if let statusMessage {
                    Text(statusMessage).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
    }

    private var healthBridgeCard: some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Apple Health هو الجسر", systemImage: "heart.text.square")
                    .font(.headline)
                    .foregroundStyle(WarifBrand.sage)
                Text(healthAvailable == false
                     ? "Apple Health غير متاح على هذا الجهاز. يمكنك استخدام وريف بدون جهاز قابل للارتداء."
                     : "أي ساعة أو جهاز تختارين مزامنته مع Apple Health يمكن أن يضيف ملخصات للنوم والنشاط والنبض داخل وريف.")
                    .font(.subheadline)
                    .foregroundStyle(WarifBrand.mutedText)
                NavigationLink("إدارة أذونات بيانات الصحة") { ConnectedHealthView() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WarifBrand.berry)
            }
        }
    }

    private var compatibilityCard: some View {
        WarifCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("توافق قابل للتوسعة").font(.headline)
                compatibilityRow("Apple Watch", detail: "ربط مباشر وملخص يومي على الساعة")
                compatibilityRow("ساعات وأجهزة Apple Health", detail: "تظهر بياناتها عند مزامنتها عبر Apple Health")
                compatibilityRow("Garmin وFitbit وWithings وغيرها", detail: "تحتاج مزامنة إلى Apple Health أو موفّر شريك معتمد")
            }
        }
    }

    private var privacyNote: some View {
        Text("لا تُنقل إلى الساعة قياسات صحية خام أو ملاحظات خاصة أو موقع. يصل إليها عنوان عام وخطوة مقترحة فقط.")
            .font(.footnote)
            .foregroundStyle(WarifBrand.berryStrong)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func compatibilityRow(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(detail).font(.footnote).foregroundStyle(.secondary)
        }
    }

    private var statusColor: Color {
        switch environment.wearables.status {
        case .installed: WarifBrand.sage
        case .ready: WarifBrand.berry
        case .notPaired, .unavailable: WarifBrand.mutedText
        }
    }

    private func syncToday() {
        guard syncToWatch else { return }
        environment.wearables.sync(WatchCompanionPayload(
            titleAr: "وريف اليوم",
            actionAr: "خذي لحظة لتسجيل يومك.",
            updatedAt: .now
        ))
        statusMessage = environment.wearables.status == .installed
            ? "تم إرسال ملخص عام إلى الساعة."
            : "اربطي Apple Watch وثبّتي امتداد وريف على الساعة لتفعيل المزامنة المباشرة."
    }
}

#Preview {
    NavigationStack { WearablesView() }
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
