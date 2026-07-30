import SwiftUI

/// Notification preferences. Lock-screen copy is always generic
/// («لديك تحديث من وريف») — no health values, symptoms, or cycle data.
struct NotificationsView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var cycleReminders = true
    @State private var checkInReminders = true
    @State private var communityReplies = false
    @State private var reminderTime = Date.now
    @State private var statusMessage: String?

    var body: some View {
        List {
            Section {
                Text("الإشعارات عامة افتراضياً: «لديك تحديث من وريف». لا تظهر أي معلومة صحية على شاشة القفل.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("التذكيرات") {
                Toggle("تذكير قرب موعد الدورة", isOn: $cycleReminders)
                    .onChange(of: cycleReminders) { _, enabled in scheduleCycleReminder(enabled) }
                Toggle("تذكير التسجيل اليومي", isOn: $checkInReminders)
                    .onChange(of: checkInReminders) { _, enabled in scheduleDailyReminder(enabled) }
                DatePicker("وقت التذكير اليومي", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .onChange(of: reminderTime) { _, _ in scheduleDailyReminder(checkInReminders) }
                Toggle("ردود المجتمع", isOn: $communityReplies)
            }
            if let statusMessage {
                Section { Text(statusMessage).font(.footnote).foregroundStyle(.secondary) }
            }
        }
        .navigationTitle("الإشعارات")
    }

    private func scheduleDailyReminder(_ enabled: Bool) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        Task {
            do {
                try await environment.notifications.setDailyCheckIn(
                    enabled: enabled, hour: components.hour ?? 20, minute: components.minute ?? 0
                )
                statusMessage = enabled ? "تم تحديث تذكير وريف اليومي." : "تم إيقاف تذكير وريف اليومي."
            } catch {
                statusMessage = "تعذر تحديث الإشعار. تحققي من إذن الإشعارات في إعدادات iPhone."
            }
        }
    }

    private func scheduleCycleReminder(_ enabled: Bool) {
        Task {
            do {
                try await environment.notifications.setCycleReminder(enabled: enabled)
                statusMessage = enabled ? "تم تحديث تذكير وريف العام." : "تم إيقاف التذكير العام."
            } catch {
                statusMessage = "تعذر تحديث الإشعار. تحققي من إذن الإشعارات في إعدادات iPhone."
            }
        }
    }
}

#Preview {
    NavigationStack { NotificationsView() }
        .environment(\.layoutDirection, .rightToLeft)
}
