import Foundation

/// Deterministic mock used for previews and automated tests (spec: real
/// HealthKit is validated only on a physical device).
struct MockHealthDataProvider: HealthDataProviding {
    var available = true
    var hasData = true

    func isAvailable() async -> Bool { available }
    func requestReadAuthorization(for metrics: Set<HealthMetric>) async throws {}

    func dailySummaries(
        metrics: Set<HealthMetric>,
        interval: DateInterval,
        calendar: Calendar
    ) async throws -> [DailyHealthSummary] {
        guard hasData else { return [] }
        var day = calendar.startOfDay(for: interval.start)
        var out: [DailyHealthSummary] = []
        var seed = 0
        while day < interval.end {
            out.append(
                DailyHealthSummary(
                    day: day,
                    restingHeartRate: 60 + Double(seed % 6),
                    hrvSDNN: 40 + Double(seed % 20),
                    steps: 5000 + (seed % 5) * 800,
                    activeEnergyKcal: 300 + Double(seed % 4) * 40,
                    sleepHours: 6.5 + Double(seed % 3) * 0.5
                )
            )
            day = calendar.date(byAdding: .day, value: 1, to: day) ?? interval.end
            seed += 1
        }
        return out
    }
}
