import SwiftUI

struct PendingActivationView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 56))
                .foregroundStyle(WarifBrand.berry)
            Text("وصلنا طلبك يا هلا")
                .font(.title2.bold())
                .foregroundStyle(WarifBrand.textPlum)
            Text("حسابك قيد المراجعة، وبنرسل لك إشعار أول ما يتم تفعيله. تبدأ تجربة الـ14 يوماً عند اعتماد الإدارة من وقت الخادم.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            // Demo-only shortcut standing in for the server-side admin approval.
            Button("محاكاة التفعيل (عرض تجريبي)") { router.state = .trialing }
                .warifPrimaryButton()
        }
        .padding()
        .background(WarifBrand.ivory)
    }
}

#Preview {
    PendingActivationView()
        .environment(AppRouter())
        .environment(\.layoutDirection, .rightToLeft)
}
