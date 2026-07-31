import Foundation
import Observation
import SwiftUI
@preconcurrency import WatchConnectivity

@main
struct WarifWatchApp: App {
    @State private var session = WarifWatchSession()

    var body: some Scene {
        WindowGroup {
            WatchTodayView()
                .environment(session)
        }
    }
}

private struct WatchPayload: Codable {
    let titleAr: String
    let actionAr: String
    let updatedAt: Date
}

@MainActor
@Observable
final class WarifWatchSession: NSObject {
    var title = "وريف اليوم"
    var action = "افتحي وريف على iPhone لتجهيز يومك."

    private let session = WCSession.default

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
        apply(session.receivedApplicationContext)
    }

    private func apply(_ context: [String: Any]) {
        guard let data = context["warif.watch.payload"] as? Data,
              let payload = try? JSONDecoder().decode(WatchPayload.self, from: data)
        else { return }
        title = payload.titleAr
        action = payload.actionAr
    }
}

extension WarifWatchSession: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {}

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor [weak self] in self?.apply(applicationContext) }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

private struct WatchTodayView: View {
    @Environment(WarifWatchSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.pink)
            Text(session.title)
                .font(.headline)
            Text(session.action)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("بياناتك الخاصة تبقى على iPhone")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .scenePadding()
    }
}
