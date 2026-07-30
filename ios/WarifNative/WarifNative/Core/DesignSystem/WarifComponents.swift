import SwiftUI

struct WarifCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(hex: "#FFFFFF"))
            .clipShape(RoundedRectangle(cornerRadius: WarifBrand.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WarifBrand.cardCornerRadius)
                    .stroke(Color(hex: "#EADDE2"), lineWidth: 1)
            )
            .shadow(color: WarifBrand.berry.opacity(0.06), radius: 12, y: 4)
    }
}

struct WarifPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: WarifBrand.minTouchTarget)
            .padding(.horizontal, 20)
            .background(WarifBrand.berry)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension View {
    func warifPrimaryButton() -> some View { buttonStyle(WarifPrimaryButtonStyle()) }
}
