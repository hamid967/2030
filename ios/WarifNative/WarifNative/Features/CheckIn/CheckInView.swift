import SwiftUI

/// Quick daily check-in (under 30 seconds). Sensitive values stay on device
/// and never appear in logs/analytics/notifications.
struct CheckInView: View {
    @Environment(AppEnvironment.self) private var environment

    @State private var flow = 0
    @State private var pain = 0
    @State private var mood = 3
    @State private var energy = 3
    @State private var sleep = 3
    @State private var saved = false

    private let flowLabels = ["لا يوجد", "خفيف", "متوسط", "غزير"]

    var body: some View {
        NavigationStack {
            Form {
                Section("شدة النزف") {
                    Picker("النزف", selection: $flow) {
                        ForEach(0..<flowLabels.count, id: \.self) { Text(flowLabels[$0]).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("الألم") {
                    Stepper("الشدة: \(pain)/10", value: $pain, in: 0...10)
                }
                scaleSection("المزاج", value: $mood)
                scaleSection("الطاقة", value: $energy)
                scaleSection("النوم", value: $sleep)

                Section {
                    Button("حفظ اليوم") { Task { await save() } }
                        .warifPrimaryButton()
                        .listRowInsets(EdgeInsets())
                    if saved {
                        Label("تم تسجيل يومك ✓ كل تسجيل يساعد وريف يفهم نمطك بشكل أدق.",
                              systemImage: "checkmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(WarifBrand.berry)
                    }
                }
            }
            .navigationTitle("تسجيل اليوم")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func scaleSection(_ title: String, value: Binding<Int>) -> some View {
        Section(title) {
            Picker(title, selection: value) {
                ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    private func save() async {
        let entry = DailyCheckIn(
            date: Date(), flow: flow, painIntensity: pain,
            mood: mood, energy: energy, sleep: sleep, notes: nil
        )
        await environment.checkIn.save(entry)
        saved = true
    }
}

#Preview {
    CheckInView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
