import SwiftUI

/// Notification preferences. Lock-screen copy is always generic
/// («لديك تحديث من وريف») — no health values, symptoms, or cycle data.
struct NotificationsView: View {
    @State private var cycleReminders = true
    @State private var checkInReminders = true
    @State private var communityReplies = false

    var body: some View {
        List {
            Section {
                Text("الإشعارات عامة افتراضياً: «لديك تحديث من وريف». لا تظهر أي معلومة صحية على شاشة القفل.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("التذكيرات") {
                Toggle("تذكير قرب موعد الدورة", isOn: $cycleReminders)
                Toggle("تذكير التسجيل اليومي", isOn: $checkInReminders)
                Toggle("ردود المجتمع", isOn: $communityReplies)
            }
        }
        .navigationTitle("الإشعارات")
    }
}

#Preview {
    NavigationStack { NotificationsView() }
        .environment(\.layoutDirection, .rightToLeft)
}
