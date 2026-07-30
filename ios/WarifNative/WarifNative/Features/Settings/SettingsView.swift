import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("التخصيص") {
                NavigationLink("ثيم المنطقة") { RegionalThemePickerView() }
            }
            Section("الصحة") {
                NavigationLink("ربط تطبيق صحتي") { ConnectedHealthView() }
            }
            Section("الخصوصية") {
                NavigationLink("مركز الخصوصية") { PrivacyCenterView() }
            }
        }
        .navigationTitle("الإعدادات")
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
