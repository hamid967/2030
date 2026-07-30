import Foundation
import CryptoKit

/// Sign in with Apple nonce helpers.
///
/// A random nonce is generated per sign-in; its SHA-256 hash is sent to Apple
/// in the authorization request, and the raw nonce is later handed to the
/// backend to verify the returned identity token. The raw nonce is never
/// logged or persisted beyond the in-flight request.
enum AppleNonce {
    private static let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")

    /// Cryptographically random nonce string.
    static func random(length: Int = 32) -> String {
        precondition(length > 0)
        var result = ""
        var remaining = length
        while remaining > 0 {
            var bytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            guard status == errSecSuccess else {
                // Fallback (should not happen); still non-sequential.
                bytes = (0..<16).map { _ in UInt8.random(in: 0...255) }
            }
            for byte in bytes where remaining > 0 {
                result.append(charset[Int(byte) % charset.count])
                remaining -= 1
            }
        }
        return result
    }

    /// Lowercase hex SHA-256 of the input (what is sent to Apple).
    static func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
