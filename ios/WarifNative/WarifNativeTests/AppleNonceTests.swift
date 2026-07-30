import XCTest
@testable import WarifNative

final class AppleNonceTests: XCTestCase {
    func testSha256MatchesKnownVector() {
        // SHA-256("abc") — a well-known test vector.
        XCTAssertEqual(
            AppleNonce.sha256("abc"),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
    }

    func testRandomNonceHasRequestedLengthAndVaries() {
        let a = AppleNonce.random(length: 32)
        let b = AppleNonce.random(length: 32)
        XCTAssertEqual(a.count, 32)
        XCTAssertEqual(b.count, 32)
        XCTAssertNotEqual(a, b)
    }

    func testHashIsStableAndDiffersFromRaw() {
        let nonce = "test-nonce-123"
        XCTAssertEqual(AppleNonce.sha256(nonce), AppleNonce.sha256(nonce))
        XCTAssertNotEqual(AppleNonce.sha256(nonce), nonce)
        XCTAssertEqual(AppleNonce.sha256(nonce).count, 64)
    }
}
