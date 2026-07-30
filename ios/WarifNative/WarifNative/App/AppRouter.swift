import SwiftUI
import Observation

@MainActor
@Observable
final class AppRouter {
    var state: RootState = .launching

    func bootstrap(environment: AppEnvironment) async {
        let authState = await environment.auth.currentState()
        // A region must be selected before entering the member experience.
        if authState == .trialing || authState == .active,
           !environment.regionTheme.hasSelectedRegion {
            state = .selectingRegion
        } else {
            state = authState
        }
    }
}
