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

enum HealthAuthorizationState: Sendable {
    case notDetermined
    case requested
    case unavailable
}

/// On-device daily aggregate. Raw samples never leave the device.
struct DailyHealthSummary: Identifiable, Sendable {
    var id: Date { day }
    let day: Date
    var restingHeartRate: Double?
    var hrvSDNN: Double?
    var steps: Int?
    var activeEnergyKcal: Double?
    var sleepHours: Double?
}
