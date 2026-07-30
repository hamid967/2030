import XCTest
@testable import WarifNative

final class DailyInsightEngineTests: XCTestCase {
    private let calendar = WarifCalendar.riyadh

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }

    func testHighPainCreatesCautionInsightAndDoctorAction() {
        let insight = DailyInsightEngine.generate(
            DailyInsightInput(
                cyclePhase: .menstruation,
                cycleDay: 2,
                prediction: nil,
                checkIns: [
                    DailyCheckIn(
                        date: date(2026, 7, 1), flow: 2, painIntensity: 8,
                        mood: 2, energy: 2, sleep: 2, notes: nil
                    ),
                ],
                healthSummaries: [],
                region: .riyadh,
                wellnessProfile: .starter
            )
        )

        XCTAssertEqual(insight.tone, .caution)
        XCTAssertTrue(insight.actions.contains { $0.kind == .doctor })
        XCTAssertTrue(insight.evidenceAr.contains { $0.contains("8/10") })
    }

    func testLowSleepCreatesSleepFocusedInsight() {
        let insight = DailyInsightEngine.generate(
            DailyInsightInput(
                cyclePhase: .luteal,
                cycleDay: 24,
                prediction: CyclePrediction(
                    confidence: .medium,
                    sampleCount: 4,
                    cyclesUsed: 5,
                    medianCycleLength: 28,
                    dataThroughDate: nil,
                    estimatedDate: nil,
                    earliestDate: nil,
                    latestDate: nil
                ),
                checkIns: [],
                healthSummaries: [
                    DailyHealthSummary(day: date(2026, 7, 1), sleepHours: 5.8),
                    DailyHealthSummary(day: date(2026, 7, 2), sleepHours: 6.0),
                ],
                region: .jazan,
                wellnessProfile: .starter
            )
        )

        XCTAssertEqual(insight.tone, .encouraging)
        XCTAssertTrue(insight.actions.contains { $0.kind == .sleep })
        XCTAssertTrue(insight.evidenceAr.contains { $0.contains("متوسط النوم") })
    }
}
