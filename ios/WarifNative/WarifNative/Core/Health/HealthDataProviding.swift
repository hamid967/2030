import Foundation

/// Views depend on this protocol, never on HKHealthStore directly.
protocol HealthDataProviding: Sendable {
    /// Whether Health data is available on this device (iPad/Simulator may not).
    func isAvailable() async -> Bool
    func requestReadAuthorization(for metrics: Set<HealthMetric>) async throws
    /// On-device daily aggregates for the interval. Raw samples are not exposed.
    func dailySummaries(
        metrics: Set<HealthMetric>,
        interval: DateInterval,
        calendar: Calendar
    ) async throws -> [DailyHealthSummary]
}
