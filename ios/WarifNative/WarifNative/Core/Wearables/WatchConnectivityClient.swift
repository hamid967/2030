@preconcurrency import WatchConnectivity
import Foundation
import Observation

@MainActor
protocol WearableSyncing {
    var status: WearableConnectionStatus { get }
    func start()
    func sync(_ payload: WatchCompanionPayload)
}

@MainActor
@Observable
final class WatchConnectivityClient: NSObject, WearableSyncing {
    private let session: WCSession? = WCSession.isSupported() ? .default : nil
    private(set) var status: WearableConnectionStatus = .unavailable

    override init() {
        super.init()
        start()
    }

    func start() {
        guard let session else {
            status = .unavailable
            return
        }
        session.delegate = self
        session.activate()
        refreshStatus()
    }

    func sync(_ payload: WatchCompanionPayload) {
        guard let session, status == .installed else { return }
        guard let data = try? JSONEncoder().encode(payload) else { return }
        do {
            try session.updateApplicationContext(["warif.watch.payload": data])
        } catch {
            // The next successful app activation will refresh the companion state.
        }
    }

    private func refreshStatus() {
        guard let session else {
            status = .unavailable
            return
        }
        if !session.isPaired { status = .notPaired }
        else if session.isWatchAppInstalled { status = .installed }
        else { status = .ready }
    }
}

extension WatchConnectivityClient: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        Task { @MainActor in refreshStatus() }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

@MainActor
final class MockWearableSync: WearableSyncing {
    var status: WearableConnectionStatus = .installed
    func start() {}
    func sync(_ payload: WatchCompanionPayload) {}
}
