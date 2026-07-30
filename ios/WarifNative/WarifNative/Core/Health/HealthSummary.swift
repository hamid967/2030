import Foundation

enum HealthAuthorizationState: Sendable {
    case notDetermined
    case requested
    case unavailable
}

/// On-device daily aggregate. Raw samples never leave the device.
struct DailyHealthSummary: Identifiable, Sendable {
    var id: Date { day }
    let day: Date
    var averageHeartRate: Double? = nil
    var restingHeartRate: Double? = nil
    var hrvSDNN: Double? = nil
    var steps: Int? = nil
    var activeEnergyKcal: Double? = nil
    var sleepHours: Double? = nil
}
