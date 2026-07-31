import LocalAuthentication
import SwiftUI

struct PrivacyCenterView: View {
    @Environment(AppEnvironment.self) private var environment
    @AppStorage("warif.privacy.faceIDLock") private var faceIDLock = false
    @State private var exportText: String?
    @State private var statusMessage: String?

    var body: some View {
        List {
            Section {
                Text("بياناتك الصحية محفوظة على هذا الجهاز فقط ولا تُرسل إلى أي خادم. لا نضع قيماً صحية في الإشعارات أو الروابط أو أدوات التحليل.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("الأمان") {
                Toggle("قفل بالـFace ID", isOn: Binding(
                    get: { faceIDLock },
                    set: { enabled in
                        enabled ? enableFaceIDLock() : (faceIDLock = false)
                    }
                ))
            }
            Section("الإشعارات") {
                Text("الإشعارات عامة افتراضياً: «لديك تحديث من وريف».")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("بياناتك") {
                Button("تجهيز نسخة بياناتي") { Task { await prepareExport() } }
                if let exportText {
                    ShareLink(item: exportText) {
                        Label("مشاركة ملف البيانات", systemImage: "square.and.arrow.up")
                    }
                }
                Button("سحب الموافقة") { Task { await withdrawConsent() } }
                Button("حذف بياناتي", role: .destructive) { Task { await deleteLocalData() } }
            }
            if let statusMessage {
                Section {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("مركز الخصوصية")
    }

    private func enableFaceIDLock() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            statusMessage = "ميزة القفل غير مفعلة على هذا الجهاز."
            faceIDLock = false
            return
        }
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "تأكيد قفل وريف قبل عرض البيانات الحساسة"
        ) { success, _ in
            Task { @MainActor in
                faceIDLock = success
                statusMessage = success
                    ? "تم تفعيل قفل الخصوصية."
                    : "لم يتم تفعيل قفل الخصوصية."
            }
        }
    }

    private func prepareExport() async {
        let today = Date()
        let export = PrivacyExport(
            exportedAt: today,
            member: await environment.member.profile().map(ExportMember.init),
            cycleProfile: await environment.cycle.getProfile(),
            recentCheckIns: await environment.checkIn.recent(days: 90, endingOn: today),
            wellnessProfile: await environment.wellnessProfile.load(),
            regionPreference: environment.regionTheme.preference
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(export),
           let value = String(data: data, encoding: .utf8) {
            exportText = value
            statusMessage = "تم تجهيز نسخة بياناتك محلياً."
        } else {
            statusMessage = "تعذر تجهيز نسخة البيانات الآن."
        }
    }

    private func withdrawConsent() async {
        var profile = await environment.wellnessProfile.load()
        profile.communityEnabled = false
        profile.sensitiveModeEnabled = true
        do {
            try await environment.wellnessProfile.save(profile)
            try await environment.notifications.setSmartReminder(nil)
            statusMessage = "تم سحب الموافقة للميزات الاختيارية."
        } catch {
            statusMessage = "تعذر تحديث الموافقات الآن."
        }
    }

    private func deleteLocalData() async {
        do {
            await environment.cycle.clearProfile()
            await environment.checkIn.clearAll()
            try await environment.wellnessProfile.reset()
            environment.regionTheme.reset()
            try await environment.notifications.setDailyCheckIn(enabled: false, hour: 20, minute: 0)
            try await environment.notifications.setCycleReminder(enabled: false, profile: nil, today: Date())
            try await environment.notifications.setSmartReminder(nil)
            await environment.auth.signOut()
            exportText = nil
            statusMessage = "تم حذف بيانات وريف المحلية من هذا الجهاز."
        } catch {
            statusMessage = "تعذر حذف كل البيانات المحلية الآن."
        }
    }
}

private struct PrivacyExport: Codable {
    let exportedAt: Date
    let member: ExportMember?
    let cycleProfile: CycleProfile?
    let recentCheckIns: [DailyCheckIn]
    let wellnessProfile: WellnessProfile
    let regionPreference: RegionPreference?
}

private struct ExportMember: Codable {
    let id: String
    let displayName: String
    let region: SaudiRegion?

    init(_ profile: MemberProfile) {
        id = profile.id
        displayName = profile.displayName
        region = profile.region
    }
}

#Preview {
    NavigationStack { PrivacyCenterView() }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(AppEnvironment.preview())
}
