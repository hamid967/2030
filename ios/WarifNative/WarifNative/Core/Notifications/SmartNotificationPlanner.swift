import Foundation

enum SmartNotificationPlanner {
    /// At most one gentle check-in nudge is scheduled per day. The body is
    /// intentionally generic and never contains cycle, symptom, or health data.
    static func plan(
        for input: SmartReminderInput,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> SmartReminderPlan? {
        guard !input.hasCheckedInToday else { return nil }
        guard !input.quietHours.contains(input.currentHour) else { return nil }

        let targetHour = input.currentHour < 18 ? 18 : (input.currentHour < 20 ? 20 : 18)
        let body: String
        switch input.cyclePhase {
        case .menstruation?: body = "لديك مساحة صغيرة للاهتمام بنفسك اليوم."
        case .luteal?: body = "خذي لحظة هادئة لتسجيل يومك عندما يناسبك."
        default: body = "لحظة قصيرة الآن قد تصنع صورة أوضح ليومك."
        }
        let startsTomorrow = input.currentHour >= 20
        let baseDate = startsTomorrow
            ? (calendar.date(byAdding: .day, value: 1, to: now) ?? now)
            : now
        let fire = calendar.date(bySettingHour: targetHour, minute: 0, second: 0, of: baseDate) ?? baseDate
        return SmartReminderPlan(
            identifier: "warif.smart.daily",
            title: "وريف",
            body: body,
            fireDate: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        )
    }
}
