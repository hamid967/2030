import Foundation

/// The read-only Health metrics used in the MVP.
enum HealthMetric: String, CaseIterable, Sendable {
    case heartRate
    case restingHeartRate
    case walkingHeartRateAverage
    case heartRateVariability
    case steps
    case activeEnergy
    case sleep
}

