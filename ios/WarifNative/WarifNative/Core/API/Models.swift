import Foundation

struct MemberProfile: Sendable, Identifiable {
    let id: String
    var displayName: String
    var region: SaudiRegion?
}

struct CycleProfile: Sendable, Codable {
    var lastPeriodStart: Date
    var cycleLength: Int
    var periodLength: Int
    var periodStarts: [Date]
}

struct DailyCheckIn: Sendable, Codable, Identifiable {
    var id: Date { date }
    var date: Date
    var flow: Int          // 0 none … 3 heavy
    var painIntensity: Int // 0…10
    var mood: Int          // 1…5
    var energy: Int        // 1…5
    var sleep: Int         // 1…5
    var notes: String?
}

struct Article: Sendable, Identifiable {
    enum Category: String, Sendable, CaseIterable {
        case cycle, pain, hormones, fertility, mental, nutrition, doctor
    }
    let id: String
    let category: Category
    let titleAr: String
    let titleEn: String
    let summaryAr: String
    let summaryEn: String
    let readingMinutes: Int
    let reviewer: String?
    let experimental: Bool
}

struct CommunitySpace: Sendable, Identifiable {
    let id: String
    let nameAr: String
    let nameEn: String
}

struct CommunityPost: Sendable, Identifiable {
    let id: String
    let spaceId: String
    let pseudonym: String
    let bodyAr: String
    let bodyEn: String
    let reactions: Int
    let comments: Int
}
