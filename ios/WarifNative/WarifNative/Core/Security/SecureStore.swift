import Foundation
import Security

/// Abstraction over secure storage (Keychain). Sessions and encryption keys go
/// here — never in UserDefaults.
protocol SecureStore: Sendable {
    func setString(_ value: String, for key: String) throws
    func string(for key: String) -> String?
    func remove(_ key: String) throws
}

/// Keychain-backed secure store.
struct KeychainSecureStore: SecureStore {
    let service: String

    init(service: String = "sa.warif.app") { self.service = service }

    func setString(_ value: String, for key: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw SecureStoreError.status(status) }
    }

    func string(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func remove(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStoreError.status(status)
        }
    }
}

enum SecureStoreError: Error { case status(OSStatus) }

/// In-memory store for previews and tests (never used in production).
final class InMemorySecureStore: SecureStore, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: String] = [:]

    func setString(_ value: String, for key: String) throws {
        lock.withLock { storage[key] = value }
    }
    func string(for key: String) -> String? {
        lock.withLock { storage[key] }
    }
    func remove(_ key: String) throws {
        _ = lock.withLock { storage.removeValue(forKey: key) }
    }
}
