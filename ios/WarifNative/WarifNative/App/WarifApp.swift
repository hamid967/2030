import SwiftUI

@main
struct WarifApp: App {
    @State private var environment = AppEnvironment.local()
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(router)
                // Arabic-first with full RTL mirroring.
                .environment(\.layoutDirection, .rightToLeft)
                .task { await router.bootstrap(environment: environment) }
        }
    }
}
