import SwiftUI

struct WelcomeView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image("OnboardingPrivacy")
                .resizable().scaledToFit()
                .frame(maxHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: WarifBrand.cardCornerRadius))
                .accessibilityLabel("امرأة هادئة تستخدم هاتفها محاطة بأوراق نباتية")
            VStack(spacing: 8) {
                Text("وريف")
                    .font(.largeTitle.bold())
                    .foregroundStyle(WarifBrand.berryStrong)
                Text("افهمي دورتك. اعتني بنفسك. لستِ وحدك.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack(spacing: 12) {
                Button("المتابعة") { router.state = .selectingRegion }
                    .warifPrimaryButton()
                Text("خصوصيتك ميزة أساسية: بياناتك الصحية تبقى على جهازك.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(WarifBrand.ivory)
    }
}

#Preview {
    WelcomeView()
        .environment(AppRouter())
        .environment(\.layoutDirection, .rightToLeft)
}
