import Foundation

/// One-shot, approximate region detection. Implementations MUST discard
/// coordinates immediately and only ever return a region (never a location).
protocol RegionLocating: Sendable {
    func detectApproximateRegion() async throws -> SaudiRegion?
}

enum RegionLocatingError: Error, Sendable {
    case permissionDenied
    case unavailable
    case couldNotDetermine
}

/// Deterministic mock for previews/tests.
struct MockRegionLocator: RegionLocating {
    var result: Result<SaudiRegion?, RegionLocatingError> = .success(.riyadh)
    func detectApproximateRegion() async throws -> SaudiRegion? {
        try result.get()
    }
}
