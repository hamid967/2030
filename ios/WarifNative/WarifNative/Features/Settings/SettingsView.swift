import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("المتابعة") {
                NavigationLink("الرؤى") { InsightsView() }
                NavigationLink("الإشعارات") { NotificationsView() }
            }
            Section("التخصيص") {
                NavigationLink("ثيم المنطقة") { RegionalThemePickerView() }
                NavigationLink("تخصيص العافية") { WellnessProfileView() }
            }
            Section("الصحة") {
                NavigationLink("ربط تطبيق صحتي") { ConnectedHealthView() }
                NavigationLink("الساعات والأجهزة") { WearablesView() }
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
