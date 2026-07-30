import XCTest
@testable import WarifNative

final class HealthAggregationTests: XCTestCase {
    func testTrendAveragesOnlyPresentValues() async {
        let calendar = WarifCalendar.riyadh
        let day0 = WarifCalendar.startOfDay(Date(), calendar)
        let summaries = [
            DailyHealthSummary(day: day0, restingHeartRate: 60, hrvSDNN: 40,
                               steps: 5000, activeEnergyKcal: 300, sleepHours: 7),
            DailyHealthSummary(day: WarifCalendar.adding(1, to: day0, calendar),
                               restingHeartRate: 62, hrvSDNN: nil,
                               steps: 7000, activeEnergyKcal: 320, sleepHours: 8),
        ]
        let trend = await HealthAggregationActor().trend(from: summaries)
        XCTAssertEqual(trend.dayCount, 2)
        XCTAssertEqual(trend.totalSteps, 12000)
        XCTAssertEqual(trend.averageRestingHeartRate, 61)
        XCTAssertEqual(trend.averageHRV, 40) // only one present value
        XCTAssertEqual(trend.averageSleepHours ?? 0, 7.5, accuracy: 0.001)
    }

    func testEmptySummariesProduceNilAverages() async {
        let trend = await HealthAggregationActor().trend(from: [])
        XCTAssertNil(trend.averageRestingHeartRate)
        XCTAssertEqual(trend.totalSteps, 0)
        XCTAssertEqual(trend.dayCount, 0)
    }
}
