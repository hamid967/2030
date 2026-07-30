import SwiftUI

struct PrivacyCenterView: View {
    @State private var faceIDLock = false

    var body: some View {
        List {
            Section {
                Text("بياناتك الصحية محفوظة على هذا الجهاز فقط ولا تُرسل إلى أي خادم. لا نضع قيماً صحية في الإشعارات أو الروابط أو أدوات التحليل.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("الأمان") {
                Toggle("قفل بالـFace ID", isOn: $faceIDLock)
            }
            Section("الإشعارات") {
                Text("الإشعارات عامة افتراضياً: «لديك تحديث من وريف».")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("بياناتك") {
                Button("تصدير بياناتي") {}
                Button("سحب الموافقة") {}
                Button("حذف بياناتي", role: .destructive) {}
            }
        }
        .navigationTitle("مركز الخصوصية")
    }
}

#Preview {
    NavigationStack { PrivacyCenterView() }
        .environment(\.layoutDirection, .rightToLeft)
}
