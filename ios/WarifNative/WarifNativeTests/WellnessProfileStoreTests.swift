import XCTest
@testable import WarifNative

final class WellnessProfileStoreTests: XCTestCase {
    func testProfileRoundTripsThroughSecureStore() async throws {
        let store = SecureWellnessProfileStore(secureStore: InMemorySecureStore())
        let expected = WellnessProfile(
            goals: [.reducePain, .prepareDoctorVisit],
            preferredSignals: [.cramps, .backPain],
            sensitiveModeEnabled: false,
            communityEnabled: true
        )

        try await store.save(expected)

        let actual = await store.load()
        XCTAssertEqual(actual, expected)
    }
}
