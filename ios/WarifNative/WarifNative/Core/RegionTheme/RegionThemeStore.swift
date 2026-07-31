import SwiftUI
import Observation

/// Persisted region preference. NOTE: coordinates are never stored — only the
/// chosen region slug, how it was chosen, and when.
struct RegionPreference: Codable, Sendable {
    var region: SaudiRegion
    var source: SaudiRegion.Source
    var updatedAt: Date
    var themeOverride: SaudiRegion?
    var useWarifBaseTheme: Bool = false
}

protocol RegionPreferenceStoring: Sendable {
    func load() -> RegionPreference?
    func save(_ preference: RegionPreference)
    func remove()
}

/// Non-sensitive preference storage. Region choice is not health data.
struct UserDefaultsRegionPreferenceStore: RegionPreferenceStoring {
    private let key = "warif.regionPreference.v1"
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func load() -> RegionPreference? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(RegionPreference.self, from: data)
    }

    func save(_ preference: RegionPreference) {
        guard let data = try? JSONEncoder().encode(preference) else { return }
        defaults.set(data, forKey: key)
    }

    func remove() {
        defaults.removeObject(forKey: key)
    }
}

@MainActor
@Observable
final class RegionThemeStore {
    private let storage: RegionPreferenceStoring
    private(set) var preference: RegionPreference?

    init(storage: RegionPreferenceStoring = UserDefaultsRegionPreferenceStore()) {
        self.storage = storage
        self.preference = storage.load()
    }

    var hasSelectedRegion: Bool { preference != nil }

    /// The theme currently applied, honoring an explicit override or base opt-in.
    var activeTheme: RegionTheme {
        guard let preference else { return .warifBase }
        if preference.useWarifBaseTheme { return .warifBase }
        if let override = preference.themeOverride {
            return .theme(for: override)
        }
        return .theme(for: preference.region)
    }

    func selectRegion(_ region: SaudiRegion, source: SaudiRegion.Source) {
        var next = preference ?? RegionPreference(
            region: region, source: source, updatedAt: Date()
        )
        next.region = region
        next.source = source
        next.updatedAt = Date()
        apply(next)
    }

    /// Override only the visual theme, without changing the profile region.
    func setThemeOverride(_ region: SaudiRegion?) {
        guard var next = preference else { return }
        next.themeOverride = region
        next.useWarifBaseTheme = false
        apply(next)
    }

    func useWarifBaseTheme(_ enabled: Bool) {
        guard var next = preference else { return }
        next.useWarifBaseTheme = enabled
        apply(next)
    }

    func reset() {
        preference = nil
        storage.remove()
    }

    private func apply(_ next: RegionPreference) {
        preference = next
        storage.save(next)
    }
}
