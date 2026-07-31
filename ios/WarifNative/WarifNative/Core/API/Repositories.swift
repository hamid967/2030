import Foundation

/// Root app/session states (mirrors the web account lifecycle; the 14-day
/// trial always starts server-side, never from the device clock).
enum RootState: Sendable, Equatable {
    case launching
    case signedOut
    case onboarding
    case selectingRegion
    case pendingAdminActivation
    case trialing
    case active
    case restricted
    case suspended
}

protocol AuthRepository: Sendable {
    func currentState() async -> RootState
    func signOut() async
}

protocol MemberRepository: Sendable {
    func profile() async -> MemberProfile?
}

protocol CycleRepository: Sendable {
    func getProfile() async -> CycleProfile?
    func saveProfile(_ profile: CycleProfile) async
    func logPeriodStart(_ date: Date) async
    func clearProfile() async
}

protocol CheckInRepository: Sendable {
    func checkIn(on date: Date) async -> DailyCheckIn?
    func save(_ checkIn: DailyCheckIn) async
    func recent(days: Int, endingOn date: Date) async -> [DailyCheckIn]
    func clearAll() async
}

protocol ContentRepository: Sendable {
    func articles() async -> [Article]
}

protocol CommunityRepository: Sendable {
    func spaces() async -> [CommunitySpace]
    func posts(in spaceId: String) async -> [CommunityPost]
}
