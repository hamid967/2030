import Foundation

/// Aggregates daily Health summaries on-device. Pure computation over values
/// already reduced to daily granularity — raw samples never reach here.
actor HealthAggregationActor {
    struct Trend: Sendable {
        var averageRestingHeartRate: Double?
        var averageHRV: Double?
        var averageSleepHours: Double?
        var totalSteps: Int
        var dayCount: Int
    }

    func trend(from summaries: [DailyHealthSummary]) -> Trend {
        func average(_ values: [Double]) -> Double? {
            values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
        }
        return Trend(
            averageRestingHeartRate: average(summaries.compactMap(\.restingHeartRate)),
            averageHRV: average(summaries.compactMap(\.hrvSDNN)),
            averageSleepHours: average(summaries.compactMap(\.sleepHours)),
            totalSteps: summaries.compactMap(\.steps).reduce(0, +),
            dayCount: summaries.count
        )
    }
}
