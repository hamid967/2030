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
    var restingHeartRate: Double?
    var hrvSDNN: Double?
    var steps: Int?
    var activeEnergyKcal: Double?
    var sleepHours: Double?
}
