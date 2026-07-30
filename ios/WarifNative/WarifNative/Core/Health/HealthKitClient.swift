import Foundation
import HealthKit

/// Live HealthKit provider. All HKHealthStore access is confined to this actor.
///
/// NOTE: Authorization + availability are wired here; on-device daily
/// aggregation via HKStatisticsCollectionQuery is intentionally left as a
/// documented TODO so we never *claim* real read integration was validated in
/// the Simulator. Automated tests use `MockHealthDataProvider`; real reads must
/// be verified on a physical device (see README physical-device matrix).
actor HealthKitClient: HealthDataProviding {
    private let store = HKHealthStore()

    func isAvailable() async -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestReadAuthorization(for metrics: Set<HealthMetric>) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let readTypes = Set(metrics.compactMap(Self.objectType(for:)))
        guard !readTypes.isEmpty else { return }
        try await store.requestAuthorization(toShare: [], read: readTypes)
    }

    func dailySummaries(
        metrics: Set<HealthMetric>,
        interval: DateInterval,
        calendar: Calendar
    ) async throws -> [DailyHealthSummary] {
        // TODO(phase-2): implement HKStatisticsCollectionQuery aggregation and
        // verify on a physical device. Returning empty keeps UI in a safe
        // "no data" state rather than presenting unverified values.
        []
    }

    private static func objectType(for metric: HealthMetric) -> HKObjectType? {
        switch metric {
        case .heartRate: HKQuantityType(.heartRate)
        case .restingHeartRate: HKQuantityType(.restingHeartRate)
        case .walkingHeartRateAverage: HKQuantityType(.walkingHeartRateAverage)
        case .heartRateVariability: HKQuantityType(.heartRateVariabilitySDNN)
        case .steps: HKQuantityType(.stepCount)
        case .activeEnergy: HKQuantityType(.activeEnergyBurned)
        case .sleep: HKCategoryType(.sleepAnalysis)
        }
    }
}
