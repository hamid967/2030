import SwiftUI
import Observation

/// Dependency container. Views read repositories/stores from here (through
/// protocols), never constructing Supabase/HealthKit/CoreLocation directly.
@MainActor
@Observable
final class AppEnvironment {
    let auth: any AuthRepository
    let member: any MemberRepository
    let cycle: any CycleRepository
    let checkIn: any CheckInRepository
    let content: any ContentRepository
    let community: any CommunityRepository
    let health: any HealthDataProviding
    let regionLocator: any RegionLocating
    let secureStore: any SecureStore
    let wellnessProfile: any WellnessProfileProviding
    let notifications: any NotificationScheduling
    let regionTheme: RegionThemeStore

    init(
        auth: any AuthRepository,
        member: any MemberRepository,
        cycle: any CycleRepository,
        checkIn: any CheckInRepository,
        content: any ContentRepository,
        community: any CommunityRepository,
        health: any HealthDataProviding,
        regionLocator: any RegionLocating,
        secureStore: any SecureStore,
        wellnessProfile: any WellnessProfileProviding,
        notifications: any NotificationScheduling,
        regionTheme: RegionThemeStore
    ) {
        self.auth = auth
        self.member = member
        self.cycle = cycle
        self.checkIn = checkIn
        self.content = content
        self.community = community
        self.health = health
        self.regionLocator = regionLocator
        self.secureStore = secureStore
        self.wellnessProfile = wellnessProfile
        self.notifications = notifications
        self.regionTheme = regionTheme
    }

    /// Local/mock environment (used until the Supabase backend layer lands).
    static func local() -> AppEnvironment {
        let secureStore = KeychainSecureStore()
        AppEnvironment(
            auth: MockAuthRepository(),
            member: MockMemberRepository(),
            cycle: MockCycleRepository(),
            checkIn: MockCheckInRepository(),
            content: MockContentRepository(),
            community: MockCommunityRepository(),
            health: HealthKitClient(),
            regionLocator: CoreLocationRegionLocator(),
            secureStore: secureStore,
            wellnessProfile: SecureWellnessProfileStore(secureStore: secureStore),
            notifications: LocalNotificationScheduler(),
            regionTheme: RegionThemeStore()
        )
    }

    static func preview() -> AppEnvironment {
        AppEnvironment(
            auth: MockAuthRepository(),
            member: MockMemberRepository(),
            cycle: MockCycleRepository(),
            checkIn: MockCheckInRepository(),
            content: MockContentRepository(),
            community: MockCommunityRepository(),
            health: MockHealthDataProvider(),
            regionLocator: MockRegionLocator(),
            secureStore: InMemorySecureStore(),
            wellnessProfile: MockWellnessProfileStore(),
            notifications: MockNotificationScheduler(),
            regionTheme: RegionThemeStore()
        )
    }
}
