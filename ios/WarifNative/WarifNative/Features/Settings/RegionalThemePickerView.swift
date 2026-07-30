import SwiftUI

struct RegionalThemePickerView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        List {
            Section {
                Button("استخدام ثيم وريف الأساسي") {
                    environment.regionTheme.useWarifBaseTheme(true)
                }
            } footer: {
                Text("يمكنك تغيير الثيم البصري دون تغيير منطقتك في الملف الشخصي.")
            }

            Section("اختاري ثيم منطقة") {
                ForEach(SaudiRegion.allCases) { region in
                    Button {
                        environment.regionTheme.setThemeOverride(region)
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(RegionTheme.theme(for: region).primary)
                                .frame(width: 28, height: 28)
                            Text(region.displayName())
                                .foregroundStyle(WarifBrand.textPlum)
                        }
                    }
                }
            }
        }
        .navigationTitle("ثيم المنطقة")
    }
}

#Preview {
    NavigationStack { RegionalThemePickerView() }
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
