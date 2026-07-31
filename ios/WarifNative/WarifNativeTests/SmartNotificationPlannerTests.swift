import XCTest
@testable import WarifNative

final class SmartNotificationPlannerTests: XCTestCase {
    func testDoesNotScheduleAfterDailyCheckIn() {
        let plan = SmartNotificationPlanner.plan(for: SmartReminderInput(
            hasCheckedInToday: true, cyclePhase: .follicular, currentHour: 12,
            quietHours: Set([22, 23, 0, 1, 2, 3, 4, 5, 6, 7])
        ))
        XCTAssertNil(plan)
    }

    func testSchedulesOneGenericEveningReminder() {
        let plan = SmartNotificationPlanner.plan(for: SmartReminderInput(
            hasCheckedInToday: false, cyclePhase: .luteal, currentHour: 15,
            quietHours: Set([22, 23, 0, 1, 2, 3, 4, 5, 6, 7])
        ))
        XCTAssertEqual(plan?.identifier, "warif.smart.daily")
        XCTAssertEqual(plan?.fireDate.hour, 18)
        XCTAssertFalse(plan?.body.contains("نبض") ?? true)
    }

    func testCycleReminderUsesPredictedPeriodWindow() {
        let calendar = WarifCalendar.riyadh
        let starts = [
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!,
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 29))!,
            calendar.date(from: DateComponents(year: 2026, month: 2, day: 26))!,
            calendar.date(from: DateComponents(year: 2026, month: 3, day: 26))!,
        ]
        let profile = CycleProfile(
            lastPeriodStart: starts.last!, cycleLength: 28, periodLength: 5, periodStarts: starts
        )
        let today = calendar.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let reminder = LocalNotificationScheduler.cycleReminderDate(
            profile: profile, today: today, calendar: calendar
        )
        let components = calendar.dateComponents([.month, .day, .hour], from: reminder!)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 21)
        XCTAssertEqual(components.hour, 9)
    }
}
