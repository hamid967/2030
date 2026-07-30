import CoreLocation

/// Live approximate-region detection.
///
/// Privacy rules (enforced here):
/// - Request When-In-Use only (never Always).
/// - Reduced accuracy; a single location request.
/// - Reverse-geocode once to `administrativeArea`, map to a region, then
///   immediately discard the coordinates (nothing is stored/uploaded).
/// - Fully usable if permission is denied (caller falls back to manual picker).
final class CoreLocationRegionLocator: NSObject, RegionLocating, CLLocationManagerDelegate, @unchecked Sendable {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    func detectApproximateRegion() async throws -> SaudiRegion? {
        let status = manager.authorizationStatus
        switch status {
        case .denied, .restricted:
            throw RegionLocatingError.permissionDenied
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }

        let location = try await requestSingleLocation()
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        let area = placemarks.first?.administrativeArea
        // Coordinates are intentionally NOT retained beyond this point.
        return RegionNormalizer.region(forAdministrativeArea: area)
    }

    private func requestSingleLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = locations.first else {
            continuation?.resume(throwing: RegionLocatingError.couldNotDetermine)
            continuation = nil
            return
        }
        continuation?.resume(returning: location)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
