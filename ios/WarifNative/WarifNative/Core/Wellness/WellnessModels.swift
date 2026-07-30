import Foundation

/// Broad product goals used to personalize copy without turning Warif into a
/// diagnostic or contraceptive tool.
enum WellnessGoal: String, Codable, CaseIterable, Sendable, Identifiable {
    case understandCycle
    case reducePain
    case improveEnergy
    case improveSleep
    case supportMood
    case tryingToConceive
    case pregnancySupport
    case prepareDoctorVisit

    var id: String { rawValue }
}

enum BodySignal: String, Codable, CaseIterable, Sendable, Identifiable {
    case cramps
    case headache
    case bloating
    case breastTenderness
    case cravings
    case acne
    case backPain
    case nausea
    case calm
    case anxious
    case energized
    case fatigued

    var id: String { rawValue }
}

enum CareActionKind: String, Codable, Sendable {
    case log
    case rest
    case movement
    case hydration
    case sleep
    case nutrition
    case breathing
    case doctor
    case privacy
    case community
}

struct CareAction: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let kind: CareActionKind
    let titleAr: String
    let bodyAr: String
    let priority: Int
}

enum InsightTone: String, Codable, Sendable {
    case calm
    case encouraging
    case caution
    case privacy
}

struct DailyInsight: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let titleAr: String
    let bodyAr: String
    let tone: InsightTone
    let actions: [CareAction]
    let evidenceAr: [String]
    let medicalDisclaimerAr: String
}

struct WellnessProfile: Codable, Sendable, Equatable {
    var goals: Set<WellnessGoal>
    var preferredSignals: Set<BodySignal>
    var sensitiveModeEnabled: Bool
    var communityEnabled: Bool

    static let starter = WellnessProfile(
        goals: [.understandCycle, .improveEnergy, .improveSleep],
        preferredSignals: [.cramps, .fatigued, .cravings, .anxious],
        sensitiveModeEnabled: true,
        communityEnabled: false
    )
}
