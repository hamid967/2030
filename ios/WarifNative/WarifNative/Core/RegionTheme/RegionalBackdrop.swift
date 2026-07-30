import SwiftUI

/// A calm, region-themed background: a soft vertical gradient plus an abstract
/// motif. Decorative only (accessibility-hidden) and never used behind medical
/// charts (those use solid surfaces).
struct RegionalBackdrop: View {
    let theme: RegionTheme
    var showMotif: Bool = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.backgroundTop, theme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            if showMotif {
                RegionalMotif(theme: theme)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
