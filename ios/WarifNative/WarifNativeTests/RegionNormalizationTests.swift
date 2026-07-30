import XCTest
@testable import WarifNative

final class RegionNormalizationTests: XCTestCase {
    func testArabicAdministrativeAreasMapToRegions() {
        XCTAssertEqual(RegionNormalizer.region(forAdministrativeArea: "منطقة الرياض"), .riyadh)
        XCTAssertEqual(RegionNormalizer.region(forAdministrativeArea: "المنطقة الشرقية"), .eastern)
        XCTAssertEqual(RegionNormalizer.region(forAdministrativeArea: "منطقة مكة المكرمة"), .makkah)
        XCTAssertEqual(RegionNormalizer.region(forAdministrativeArea: "منطقة جازان"), .jazan)
    }

    func testEnglishAdministrativeAreasMapToRegions() {
        XCTAssertEqual(RegionNormalizer.region(forAdministrativeArea: "Riyadh Province"), .riyadh)
        XCTAssertEqual(RegionNormalizer.region(forAdministrativeArea: "Eastern Province"), .eastern)
        XCTAssertEqual(RegionNormalizer.region(forAdministrativeArea: "Tabuk Region"), .tabuk)
    }

    func testUnknownAreaReturnsNil() {
        XCTAssertNil(RegionNormalizer.region(forAdministrativeArea: "Dubai"))
        XCTAssertNil(RegionNormalizer.region(forAdministrativeArea: nil))
        XCTAssertNil(RegionNormalizer.region(forAdministrativeArea: ""))
    }
}
