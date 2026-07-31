import Foundation

enum WearableKind: String, CaseIterable, Identifiable, Sendable {
    case appleWatch
    case appleHealthCompatible
    case partnerProvider

    var id: String { rawValue }
    var titleAr: String {
        switch self {
        case .appleWatch: "Apple Watch"
        case .appleHealthCompatible: "جهاز متصل بـ Apple Health"
        case .partnerProvider: "مزوّد شريك"
        }
    }
}

enum WearableConnectionStatus: Sendable, Equatable {
    case unavailable
    case notPaired
    case ready
    case installed

    var titleAr: String {
        switch self {
        case .unavailable: "غير متاح على هذا الجهاز"
        case .notPaired: "لا توجد ساعة مقترنة"
        case .ready: "الساعة مقترنة"
        case .installed: "وريف جاهز على الساعة"
        }
    }
}

/// Contains no biometrics. It is the only payload mirrored to Apple Watch.
struct WatchCompanionPayload: Codable, Sendable, Equatable {
    let titleAr: String
    let actionAr: String
    let updatedAt: Date
}

struct SmartReminderInput: Sendable {
    let hasCheckedInToday: Bool
    let cyclePhase: CyclePhase?
    let currentHour: Int
    let quietHours: Set<Int>
}

struct SmartReminderPlan: Sendable, Equatable {
    let identifier: String
    let title: String
    let body: String
    let fireDate: DateComponents
}
