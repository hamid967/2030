import Foundation
import UserNotifications

@MainActor
protocol NotificationScheduling {
    func setDailyCheckIn(enabled: Bool, hour: Int, minute: Int) async throws
    func setCycleReminder(enabled: Bool, profile: CycleProfile?, today: Date) async throws
    func setSmartReminder(_ plan: SmartReminderPlan?) async throws
}

/// All scheduled copy is intentionally generic so a notification never
/// exposes health, cycle, or symptom data on a lock screen.
struct LocalNotificationScheduler: NotificationScheduling {
    private let center = UNUserNotificationCenter.current()
    private let dailyID = "warif.daily-check-in"
    private let cycleID = "warif.cycle-reminder"
    private let smartID = "warif.smart.daily"

    static func cycleReminderDate(
        profile: CycleProfile?,
        today: Date,
        calendar: Calendar = WarifCalendar.riyadh
    ) -> Date? {
        guard let profile else { return nil }
        let predicted = CycleEngine.predict(
            periodStarts: profile.periodStarts, today: today, calendar: calendar
        )
        let nextPeriod = predicted.estimatedDate ?? nextDate(
            after: today, from: profile.lastPeriodStart, every: profile.cycleLength, calendar: calendar
        )
        guard let nextPeriod else { return nil }

        let idealReminder = WarifCalendar.adding(-2, to: nextPeriod, calendar)
        let selectedDay = idealReminder > today ? idealReminder : nextPeriod
        guard selectedDay > today else { return nil }
        return calendar.date(
            bySettingHour: 9, minute: 0, second: 0,
            of: WarifCalendar.startOfDay(selectedDay, calendar)
        )
    }

    private static func nextDate(
        after today: Date, from start: Date, every cycleLength: Int, calendar: Calendar
    ) -> Date? {
        let length = max(cycleLength, 1)
        var candidate = start
        var guardCount = 0
        while candidate <= today && guardCount < 120 {
            candidate = WarifCalendar.adding(length, to: candidate, calendar)
            guardCount += 1
        }
        return candidate > today ? candidate : nil
    }

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

    func setCycleReminder(enabled: Bool, profile: CycleProfile?, today: Date = Date()) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [cycleID])
        guard enabled else { return }
        guard let fireDate = Self.cycleReminderDate(profile: profile, today: today) else { return }
        guard try await center.requestAuthorization(options: [.alert, .badge, .sound]) else { return }

        let content = UNMutableNotificationContent()
        content.title = "وريف"
        content.body = "لديك تحديث من وريف"
        content.sound = .default
        let components = WarifCalendar.riyadh.dateComponents(
            [.year, .month, .day, .hour, .minute], from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
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
    func setCycleReminder(enabled: Bool, profile: CycleProfile?, today: Date) async throws {}
    func setSmartReminder(_ plan: SmartReminderPlan?) async throws {}
}
