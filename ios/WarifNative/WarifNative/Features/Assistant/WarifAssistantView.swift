import SwiftUI

struct WarifAssistantView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var messages: [AssistantMessage] = []
    @State private var draft = ""
    @State private var allowCloudProcessing = false
    @State private var isReplying = false
    @State private var context = AssistantContext(
        cyclePhase: nil, cycleDay: nil, insightTitle: nil, suggestedActions: [], sensitiveModeEnabled: true
    )
    @State private var voice = VoiceInputService()
    private let speaker = VoiceOutputService()

    var body: some View {
        VStack(spacing: 0) {
            consentBanner
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in messageBubble(message) }
                        if isReplying { ProgressView("يفكر وريف…") }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            composer
        }
        .background(WarifBrand.ivory)
        .navigationTitle("مساعد وريف")
        .navigationBarTitleDisplayMode(.inline)
        .task { await prepare() }
        .onDisappear { voice.stop() }
    }

    private var consentBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("السماح بمعالجة السؤال عبر خادم وريف", isOn: $allowCloudProcessing)
                .font(.footnote.weight(.semibold))
            Text(allowCloudProcessing
                 ? "يُرسل نص سؤالك وسياق مختصر فقط. لا تُرسل قياسات HealthKit الخام أو ملاحظاتك الخاصة."
                 : "الوضع المحلي مفعّل: تستخدم الإجابات المعلومات الموجودة على جهازك فقط.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.white)
        .overlay(alignment: .bottom) { Divider() }
    }

    private var composer: some View {
        VStack(spacing: 6) {
            if case .unavailable(let message) = voice.state {
                Text(message).font(.footnote).foregroundStyle(.secondary)
            }
            HStack(alignment: .bottom, spacing: 8) {
                Button {
                    Task {
                        if case .listening = voice.state {
                            voice.stop()
                            draft = voice.transcript
                        } else {
                            await voice.start()
                        }
                    }
                } label: {
                    Image(systemName: isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .foregroundStyle(isListening ? Color.red : WarifBrand.berry)
                }
                .accessibilityLabel(isListening ? "إيقاف التسجيل" : "بدء التسجيل الصوتي")

                TextField("اسألي مساعد وريف…", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button { Task { await send() } } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : WarifBrand.berry)
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isReplying)
                .accessibilityLabel("إرسال السؤال")
            }
        }
        .padding()
        .background(Color.white)
        .overlay(alignment: .top) { Divider() }
    }

    private var isListening: Bool {
        if case .listening = voice.state { return true }
        return false
    }

    private func messageBubble(_ message: AssistantMessage) -> some View {
        HStack {
            if message.role == .assistant {
                VStack(alignment: .leading, spacing: 6) {
                    Text(message.text)
                    Button { speaker.speak(message.text) } label: {
                        Label("استماع", systemImage: "speaker.wave.2")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundStyle(WarifBrand.berry)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                Spacer(minLength: 36)
            } else {
                Spacer(minLength: 36)
                Text(message.text)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(WarifBrand.berry)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .id(message.id)
    }

    private func prepare() async {
        messages = [AssistantMessage(role: .assistant, text: "مرحباً، أنا مساعد وريف. اسأليني عن طريقة تسجيل يومك أو عن أولوية عنايتك اليوم.")]
        guard let profile = await environment.cycle.getProfile() else { return }
        let day = CycleEngine.cycleDay(lastPeriodStart: profile.lastPeriodStart, cycleLength: profile.cycleLength, today: .now)
        let phase = CycleEngine.phase(cycleDay: day, periodLength: profile.periodLength, cycleLength: profile.cycleLength)
        let prediction = CycleEngine.predict(periodStarts: profile.periodStarts, today: .now)
        let checkIns = await environment.checkIn.recent(days: 7, endingOn: .now)
        let wellness = await environment.wellnessProfile.load()
        let insight = DailyInsightEngine.generate(
            DailyInsightInput(cyclePhase: phase, cycleDay: day, prediction: prediction,
                              checkIns: checkIns, healthSummaries: [],
                              region: environment.regionTheme.preference?.region, wellnessProfile: wellness)
        )
        context = AssistantContext(
            cyclePhase: WarifCopy.stateName(phase), cycleDay: day, insightTitle: insight.titleAr,
            suggestedActions: insight.actions.prefix(3).map(\.titleAr),
            sensitiveModeEnabled: wellness.sensitiveModeEnabled
        )
    }

    private func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        voice.stop()
        draft = ""
        messages.append(AssistantMessage(role: .user, text: text))
        isReplying = true
        defer { isReplying = false }
        do {
            let response = try await environment.assistant.reply(
                to: AssistantRequest(message: text, context: context, locale: "ar-SA"),
                allowCloudProcessing: allowCloudProcessing
            )
            messages.append(AssistantMessage(role: .assistant, text: response.answer))
        } catch {
            messages.append(AssistantMessage(
                role: .assistant,
                text: "تعذر الوصول للمساعد حالياً. يمكنك متابعة تسجيل يومك أو المحاولة لاحقاً."
            ))
        }
    }
}

#Preview {
    NavigationStack { WarifAssistantView() }
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
