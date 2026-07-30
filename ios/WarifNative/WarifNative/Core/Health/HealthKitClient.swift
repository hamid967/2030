import Foundation
import HealthKit

/// Live HealthKit provider. All HKHealthStore access is confined to this actor.
///
/// NOTE: Authorization + availability are wired here. Daily aggregation uses
/// HealthKit queries and must still be verified on a physical device because
/// Simulator health data is incomplete and permission behavior differs.
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
        guard HKHealthStore.isHealthDataAvailable() else { return [] }

        var summaries = makeEmptySummaries(interval: interval, calendar: calendar)

        if metrics.contains(.heartRate) {
            let values = try await dailyQuantityValues(
                metric: .heartRate, interval: interval, calendar: calendar
            )
            for (day, value) in values { summaries[day]?.averageHeartRate = value }
        }
        if metrics.contains(.restingHeartRate) {
            let values = try await dailyQuantityValues(
                metric: .restingHeartRate, interval: interval, calendar: calendar
            )
            for (day, value) in values { summaries[day]?.restingHeartRate = value }
        }
        if metrics.contains(.walkingHeartRateAverage) {
            let values = try await dailyQuantityValues(
                metric: .walkingHeartRateAverage, interval: interval, calendar: calendar
            )
            for (day, value) in values {
                if summaries[day]?.averageHeartRate == nil {
                    summaries[day]?.averageHeartRate = value
                }
            }
        }
        if metrics.contains(.heartRateVariability) {
            let values = try await dailyQuantityValues(
                metric: .heartRateVariability, interval: interval, calendar: calendar
            )
            for (day, value) in values { summaries[day]?.hrvSDNN = value }
        }
        if metrics.contains(.steps) {
            let values = try await dailyQuantityValues(
                metric: .steps, interval: interval, calendar: calendar
            )
            for (day, value) in values { summaries[day]?.steps = Int(value.rounded()) }
        }
        if metrics.contains(.activeEnergy) {
            let values = try await dailyQuantityValues(
                metric: .activeEnergy, interval: interval, calendar: calendar
            )
            for (day, value) in values { summaries[day]?.activeEnergyKcal = value }
        }
        if metrics.contains(.sleep) {
            let values = try await dailySleepHours(interval: interval, calendar: calendar)
            for (day, value) in values { summaries[day]?.sleepHours = value }
        }

        return summaries.values
            .filter { summary in
                summary.averageHeartRate != nil ||
                summary.restingHeartRate != nil ||
                summary.hrvSDNN != nil ||
                summary.steps != nil ||
                summary.activeEnergyKcal != nil ||
                summary.sleepHours != nil
            }
            .sorted { $0.day < $1.day }
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

    private func makeEmptySummaries(
        interval: DateInterval,
        calendar: Calendar
    ) -> [Date: DailyHealthSummary] {
        var out: [Date: DailyHealthSummary] = [:]
        var day = calendar.startOfDay(for: interval.start)
        while day < interval.end {
            out[day] = DailyHealthSummary(day: day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else {
                break
            }
            day = next
        }
        return out
    }

    private func dailyQuantityValues(
        metric: HealthMetric,
        interval: DateInterval,
        calendar: Calendar
    ) async throws -> [Date: Double] {
        guard let quantityType = Self.objectType(for: metric) as? HKQuantityType else {
            return [:]
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: interval.start,
            end: interval.end,
            options: [.strictStartDate]
        )
        let anchor = calendar.startOfDay(for: interval.start)
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: statisticsOptions(for: metric),
            anchorDate: anchor,
            intervalComponents: DateComponents(day: 1)
        )

        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { _, collection, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                var values: [Date: Double] = [:]
                collection?.enumerateStatistics(from: interval.start, to: interval.end) { statistics, _ in
                    let day = calendar.startOfDay(for: statistics.startDate)
                    if let value = Self.value(from: statistics, metric: metric) {
                        values[day] = value
                    }
                }
                continuation.resume(returning: values)
            }
            store.execute(query)
        }
    }

    private func dailySleepHours(
        interval: DateInterval,
        calendar: Calendar
    ) async throws -> [Date: Double] {
        guard let sleepType = Self.objectType(for: .sleep) as? HKCategoryType else {
            return [:]
        }
        let predicate = HKQuery.predicateForSamples(
            withStart: interval.start,
            end: interval.end,
            options: []
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            store.execute(query)
        }

        var totals: [Date: TimeInterval] = [:]
        for sample in samples where sample.value != HKCategoryValueSleepAnalysis.awake.rawValue {
            let boundedStart = max(sample.startDate, interval.start)
            let boundedEnd = min(sample.endDate, interval.end)
            guard boundedEnd > boundedStart else { continue }
            var cursor = boundedStart
            while cursor < boundedEnd {
                let day = calendar.startOfDay(for: cursor)
                let nextDay = calendar.date(byAdding: .day, value: 1, to: day) ?? boundedEnd
                let segmentEnd = min(nextDay, boundedEnd)
                totals[day, default: 0] += segmentEnd.timeIntervalSince(cursor)
                cursor = segmentEnd
            }
        }

        return totals.mapValues { $0 / 3600 }
    }

    private func statisticsOptions(for metric: HealthMetric) -> HKStatisticsOptions {
        switch metric {
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage, .heartRateVariability:
            [.discreteAverage]
        case .steps, .activeEnergy:
            [.cumulativeSum]
        case .sleep:
            []
        }
    }

    private static func value(from statistics: HKStatistics, metric: HealthMetric) -> Double? {
        switch metric {
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage:
            statistics.averageQuantity()?.doubleValue(
                for: HKUnit.count().unitDivided(by: .minute())
            )
        case .heartRateVariability:
            statistics.averageQuantity()?.doubleValue(for: HKUnit.secondUnit(with: .milli))
        case .steps:
            statistics.sumQuantity()?.doubleValue(for: .count())
        case .activeEnergy:
            statistics.sumQuantity()?.doubleValue(for: .kilocalorie())
        case .sleep:
            nil
        }
    }
}
