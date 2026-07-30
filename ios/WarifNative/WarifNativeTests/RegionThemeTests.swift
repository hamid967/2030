import XCTest
@testable import WarifNative

final class RegionThemeTests: XCTestCase {
    func testThereAreThirteenRegions() {
        XCTAssertEqual(SaudiRegion.allCases.count, 13)
    }

    func testEveryRegionHasArabicAndEnglishNamesAndTheme() {
        for region in SaudiRegion.allCases {
            XCTAssertFalse(region.displayNameAr.isEmpty, "\(region) missing Arabic name")
            XCTAssertFalse(region.displayNameEn.isEmpty, "\(region) missing English name")
            let theme = RegionTheme.theme(for: region)
            XCTAssertEqual(theme.id, region.slug)
            XCTAssertFalse(theme.primaryHex.isEmpty)
            XCTAssertFalse(theme.backgroundTopHex.isEmpty)
        }
    }

    @MainActor
    func testThemeStoreOverrideDoesNotChangeRegion() {
        let store = RegionThemeStore(storage: InMemoryRegionPreferenceStore())
        store.selectRegion(.riyadh, source: .manual)
        store.setThemeOverride(.jazan)
        XCTAssertEqual(store.preference?.region, .riyadh)
        XCTAssertEqual(store.activeTheme.id, SaudiRegion.jazan.slug)
    }
}

/// Test double for preference storage.
final class InMemoryRegionPreferenceStore: RegionPreferenceStoring, @unchecked Sendable {
    private var value: RegionPreference?
    func load() -> RegionPreference? { value }
    func save(_ preference: RegionPreference) { value = preference }
}
