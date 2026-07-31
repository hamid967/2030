import SwiftUI

struct WarifCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(WarifBrand.surface)
            .clipShape(RoundedRectangle(cornerRadius: WarifBrand.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WarifBrand.cardCornerRadius)
                    .stroke(WarifBrand.border, lineWidth: 1)
            )
            .shadow(color: WarifBrand.berry.opacity(0.05), radius: 8, y: 3)
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
            .clipShape(RoundedRectangle(cornerRadius: WarifBrand.controlCornerRadius))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension View {
    func warifPrimaryButton() -> some View { buttonStyle(WarifPrimaryButtonStyle()) }
}
