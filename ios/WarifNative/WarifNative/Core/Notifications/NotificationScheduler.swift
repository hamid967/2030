import Foundation
import UserNotifications

@MainActor
protocol NotificationScheduling {
    func setDailyCheckIn(enabled: Bool, hour: Int, minute: Int) async throws
    func setCycleReminder(enabled: Bool) async throws
    func setSmartReminder(_ plan: SmartReminderPlan?) async throws
}

/// All scheduled copy is intentionally generic so a notification never
/// exposes health, cycle, or symptom data on a lock screen.
struct LocalNotificationScheduler: NotificationScheduling {
    private let center = UNUserNotificationCenter.current()
    private let dailyID = "warif.daily-check-in"
    private let cycleID = "warif.cycle-reminder"
    private let smartID = "warif.smart.daily"

    func setDailyCheckIn(enabled: Bool, hour: Int, minute: Int) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [dailyID])
        guard enabled else { return }
        guard try await center.requestAuthorization(options: [.alert, .badge, .sound]) else { return }

        let content = UNMutableNotificationContent()
        content.title = "وريف"
        content.body = "لديك تحديث من وريف"
        content.sound = .default
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        try await center.add(UNNotificationRequest(identifier: dailyID, content: content, trigger: trigger))
    }

    func setCycleReminder(enabled: Bool) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [cycleID])
        guard enabled else { return }
        guard try await center.requestAuthorization(options: [.alert, .badge, .sound]) else { return }

        let content = UNMutableNotificationContent()
        content.title = "وريف"
        content.body = "لديك تحديث من وريف"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60 * 24 * 21, repeats: false)
        try await center.add(UNNotificationRequest(identifier: cycleID, content: content, trigger: trigger))
    }

    func setSmartReminder(_ plan: SmartReminderPlan?) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [smartID])
        guard let plan else { return }
        guard try await center.requestAuthorization(options: [.alert, .badge, .sound]) else { return }

        let content = UNMutableNotificationContent()
        content.title = plan.title
        content.body = plan.body
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: plan.fireDate, repeats: false)
        try await center.add(UNNotificationRequest(identifier: plan.identifier, content: content, trigger: trigger))
    }
}

struct MockNotificationScheduler: NotificationScheduling {
    func setDailyCheckIn(enabled: Bool, hour: Int, minute: Int) async throws {}
    func setCycleReminder(enabled: Bool) async throws {}
    func setSmartReminder(_ plan: SmartReminderPlan?) async throws {}
}
