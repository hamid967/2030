import Foundation

struct MockAuthRepository: AuthRepository {
    var state: RootState = .trialing
    func currentState() async -> RootState { state }
    func signOut() async {}
}

struct MockMemberRepository: MemberRepository {
    func profile() async -> MemberProfile? {
        MemberProfile(id: "demo", displayName: "نورة", region: .riyadh)
    }
}

/// In-memory cycle store seeded with a regular ~28-day history.
actor MockCycleRepository: CycleRepository {
    private var profile: CycleProfile

    init() {
        let calendar = WarifCalendar.riyadh
        let today = Date()
        let starts = (0..<5).reversed().map { i in
            WarifCalendar.adding(-(10 + i * 28), to: today, calendar)
        }
        profile = CycleProfile(
            lastPeriodStart: starts.last ?? today,
            cycleLength: 28, periodLength: 5, periodStarts: starts
        )
    }

    func getProfile() async -> CycleProfile? { profile }
    func saveProfile(_ profile: CycleProfile) async { self.profile = profile }
    func logPeriodStart(_ date: Date) async {
        var starts = Set(profile.periodStarts)
        starts.insert(WarifCalendar.startOfDay(date))
        let sorted = starts.sorted()
        profile.periodStarts = sorted
        profile.lastPeriodStart = sorted.last ?? date
    }
}

actor MockCheckInRepository: CheckInRepository {
    private var store: [Date: DailyCheckIn] = [:]

    func checkIn(on date: Date) async -> DailyCheckIn? {
        store[WarifCalendar.startOfDay(date)]
    }
    func save(_ checkIn: DailyCheckIn) async {
        store[WarifCalendar.startOfDay(checkIn.date)] = checkIn
    }
    func recent(days: Int, endingOn date: Date) async -> [DailyCheckIn] {
        (0..<days).compactMap { offset in
            store[WarifCalendar.adding(-offset, to: WarifCalendar.startOfDay(date))]
        }
    }
}

struct MockContentRepository: ContentRepository {
    func articles() async -> [Article] {
        [
            Article(id: "understanding-your-cycle", category: .cycle,
                titleAr: "كيف تعمل دورتك؟", titleEn: "How your cycle works",
                summaryAr: "نظرة هادئة على مراحل الدورة.",
                summaryEn: "A calm look at the phases.",
                readingMinutes: 4, reviewer: nil, experimental: true),
            Article(id: "period-pain-basics", category: .pain,
                titleAr: "ألم الدورة: أساسيات", titleEn: "Period pain: the basics",
                summaryAr: "أفكار عامة للعناية الذاتية.",
                summaryEn: "General self-care ideas.",
                readingMinutes: 5, reviewer: nil, experimental: true),
            Article(id: "when-to-see-a-doctor", category: .doctor,
                titleAr: "متى أراجع الطبيبة؟", titleEn: "When to see a doctor",
                summaryAr: "علامات عامة يُستحسن عندها استشارة مختصة.",
                summaryEn: "General signs to consult a specialist.",
                readingMinutes: 5, reviewer: nil, experimental: true),
        ]
    }
}

struct MockCommunityRepository: CommunityRepository {
    func spaces() async -> [CommunitySpace] {
        [
            CommunitySpace(id: "cycle-experiences", nameAr: "تجارب الدورة", nameEn: "Cycle experiences"),
            CommunitySpace(id: "pain-and-disorders", nameAr: "الألم والاضطرابات", nameEn: "Pain & disorders"),
            CommunitySpace(id: "pcos", nameAr: "تكيّس المبايض", nameEn: "PCOS"),
        ]
    }
    func posts(in spaceId: String) async -> [CommunityPost] {
        [
            CommunityPost(id: "p1", spaceId: spaceId, pseudonym: "وردة ٢١٤",
                bodyAr: "التسجيل اليومي ساعدني أفهم نمطي بهدوء.",
                bodyEn: "Daily logging helped me understand my pattern calmly.",
                reactions: 12, comments: 3),
        ]
    }
}
