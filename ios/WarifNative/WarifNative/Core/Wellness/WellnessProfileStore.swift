import Foundation

/// Stores personalisation choices as encrypted device-only Keychain data.
/// These settings are deliberately separate from health samples and analytics.
protocol WellnessProfileProviding: Sendable {
    func load() async -> WellnessProfile
    func save(_ profile: WellnessProfile) async throws
    func reset() async throws
}

struct SecureWellnessProfileStore: WellnessProfileProviding {
    private let secureStore: any SecureStore
    private let key = "wellness-profile-v1"

    init(secureStore: any SecureStore) {
        self.secureStore = secureStore
    }

    func load() async -> WellnessProfile {
        guard let value = secureStore.string(for: key),
              let data = value.data(using: .utf8),
              let profile = try? JSONDecoder().decode(WellnessProfile.self, from: data)
        else { return .starter }
        return profile
    }

    func save(_ profile: WellnessProfile) async throws {
        let data = try JSONEncoder().encode(profile)
        guard let value = String(data: data, encoding: .utf8) else { return }
        try secureStore.setString(value, for: key)
    }

    func reset() async throws {
        try secureStore.remove(key)
    }
}

struct MockWellnessProfileStore: WellnessProfileProviding {
    func load() async -> WellnessProfile { .starter }
    func save(_ profile: WellnessProfile) async throws {}
    func reset() async throws {}
}
