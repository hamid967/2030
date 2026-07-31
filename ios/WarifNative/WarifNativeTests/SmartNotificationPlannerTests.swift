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
}
