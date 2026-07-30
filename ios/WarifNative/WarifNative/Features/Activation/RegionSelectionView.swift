import SwiftUI

/// The user must select a region, but is NEVER forced to grant location.
/// Two equal paths: manual list, or optional one-shot approximate location.
struct RegionSelectionView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router

    @State private var detecting = false
    @State private var detectionMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        Task { await detect() }
                    } label: {
                        Label(
                            detecting ? "جارٍ تحديد منطقتك…" : "حدديها تلقائياً (موقع تقريبي)",
                            systemImage: "location"
                        )
                    }
                    .disabled(detecting)
                    if let detectionMessage {
                        Text(detectionMessage).font(.footnote).foregroundStyle(.secondary)
                    }
                } header: {
                    Text("اختاري منطقتك")
                } footer: {
                    Text("منح صلاحية الموقع اختياري تماماً. نقرأ موقعاً تقريبياً مرة واحدة لاقتراح المنطقة ثم نتخلص من الإحداثيات.")
                }

                Section("كل المناطق") {
                    ForEach(SaudiRegion.allCases) { region in
                        Button {
                            choose(region, source: .manual)
                        } label: {
                            HStack {
                                Text(region.displayName())
                                    .foregroundStyle(WarifBrand.textPlum)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("منطقتك في السعودية")
        }
    }

    private func choose(_ region: SaudiRegion, source: SaudiRegion.Source) {
        environment.regionTheme.selectRegion(region, source: source)
        router.state = .pendingAdminActivation
    }

    private func detect() async {
        detecting = true
        detectionMessage = nil
        defer { detecting = false }
        do {
            if let region = try await environment.regionLocator.detectApproximateRegion() {
                // Let the user confirm before saving.
                detectionMessage = "اقترحنا: \(region.displayName()). اختاريها من القائمة لتأكيدها."
            } else {
                detectionMessage = "تعذّر تحديد المنطقة تلقائياً، اختاريها يدوياً."
            }
        } catch {
            detectionMessage = "الموقع غير متاح — يمكنك اختيار منطقتك يدوياً."
        }
    }
}

#Preview {
    RegionSelectionView()
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .environment(\.layoutDirection, .rightToLeft)
}
