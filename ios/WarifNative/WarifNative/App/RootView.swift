import SwiftUI

struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router

    var body: some View {
        switch router.state {
        case .launching:
            ProgressView().controlSize(.large)
        case .signedOut, .onboarding:
            WelcomeView()
        case .selectingRegion:
            RegionSelectionView()
        case .pendingAdminActivation:
            PendingActivationView()
        case .suspended:
            PendingActivationView()
        case .trialing, .active, .restricted:
            MainTabView()
        }
    }
}

#Preview {
    RootView()
        .environment(AppEnvironment.preview())
        .environment({ let r = AppRouter(); r.state = .trialing; return r }())
        .environment(\.layoutDirection, .rightToLeft)
}
