import XCTest
@testable import WarifNative

final class CyclePredictionTests: XCTestCase {
    private let calendar = WarifCalendar.riyadh

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }

    func testInsufficientWithSingleStart() {
        let p = CycleEngine.predict(
            periodStarts: [date(2026, 1, 1)], today: date(2026, 1, 10), calendar: calendar
        )
        XCTAssertEqual(p.confidence, .insufficient)
        XCTAssertNil(p.estimatedDate)
        XCTAssertEqual(p.cyclesUsed, 1)
    }

    func testLowConfidenceWithSingleInterval() {
        let p = CycleEngine.predict(
            periodStarts: [date(2026, 1, 1), date(2026, 1, 29)],
            today: date(2026, 2, 10), calendar: calendar
        )
        XCTAssertEqual(p.confidence, .low)
        XCTAssertEqual(p.medianCycleLength, 28)
        XCTAssertNotNil(p.estimatedDate)
    }

    func testHighConfidenceForRegularHistory() {
        let starts = [
            date(2026, 1, 1), date(2026, 1, 29), date(2026, 2, 26),
            date(2026, 3, 26), date(2026, 4, 23), date(2026, 5, 21), date(2026, 6, 18),
        ]
        let p = CycleEngine.predict(
            periodStarts: starts, today: date(2026, 6, 20), calendar: calendar
        )
        XCTAssertEqual(p.medianCycleLength, 28)
        XCTAssertEqual(p.sampleCount, 6)
        XCTAssertEqual(p.confidence, .high)
        if let estimated = p.estimatedDate {
            XCTAssertGreaterThan(estimated, date(2026, 6, 20))
        } else {
            XCTFail("expected an estimated date")
        }
    }

    func testCycleDayWrapsAcrossCycle() {
        let day = CycleEngine.cycleDay(
            lastPeriodStart: date(2026, 1, 1), cycleLength: 28,
            today: date(2026, 1, 29), calendar: calendar
        )
        XCTAssertEqual(day, 1)
    }

    func testRiyadhDayBoundary() {
        // 21:30 UTC on Jan 1 is 00:30 Jan 2 in Riyadh (UTC+3).
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let instant = utc.date(
            from: DateComponents(year: 2026, month: 1, day: 1, hour: 21, minute: 30)
        )!
        let start = WarifCalendar.startOfDay(instant, calendar)
        let comps = calendar.dateComponents([.year, .month, .day], from: start)
        XCTAssertEqual(comps.day, 2)
        XCTAssertEqual(comps.month, 1)
    }
}
