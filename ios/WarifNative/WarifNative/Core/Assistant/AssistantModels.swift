import Foundation

enum AssistantRole: String, Codable, Sendable {
    case user
    case assistant
}

struct AssistantMessage: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let role: AssistantRole
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), role: AssistantRole, text: String, createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

/// Deliberately minimal context. Raw HealthKit samples, notes, location
/// coordinates, account identifiers, and precise dates never enter this type.
struct AssistantContext: Codable, Sendable {
    let cyclePhase: String?
    let cycleDay: Int?
    let insightTitle: String?
    let suggestedActions: [String]
    let sensitiveModeEnabled: Bool
}

struct AssistantRequest: Codable, Sendable {
    let message: String
    let context: AssistantContext
    let locale: String
}

struct AssistantResponse: Codable, Sendable {
    let answer: String
    let suggestedPrompts: [String]
    let requiresProfessionalCare: Bool
}

enum AssistantSafetyPolicy {
    static func urgentResponse(for message: String) -> AssistantResponse? {
        let normalized = message.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let urgentTerms = ["انتحار", "إيذاء نفسي", "نزيف شديد", "اغماء", "إغماء", "ضيق تنفس", "ألم صدر"]
        guard urgentTerms.contains(where: normalized.contains) else { return nil }
        return AssistantResponse(
            answer: "يبدو أن ما تصفينه قد يحتاج دعماً عاجلاً. لا تعتمدي على وريف في هذه الحالة؛ تواصلي فوراً مع خدمات الطوارئ المحلية أو شخص موثوق أو مختصة.",
            suggestedPrompts: [],
            requiresProfessionalCare: true
        )
    }
}

protocol WarifAssistantProviding: Sendable {
    func reply(to request: AssistantRequest, allowCloudProcessing: Bool) async throws -> AssistantResponse
}

struct LocalWarifAssistant: WarifAssistantProviding {
    func reply(to request: AssistantRequest, allowCloudProcessing: Bool) async throws -> AssistantResponse {
        if let urgent = AssistantSafetyPolicy.urgentResponse(for: request.message) { return urgent }

        let focus = request.context.suggestedActions.first ?? "تسجيل ما تشعرين به اليوم"
        let phase = request.context.cyclePhase.map { "أنت الآن في مرحلة \($0). " } ?? ""
        return AssistantResponse(
            answer: "\(phase)أستطيع مساعدتك على قراءة تسجيلاتك بهدوء. كبداية، جربي: \(focus). هذه معلومات تثقيفية وليست تشخيصاً طبياً.",
            suggestedPrompts: ["كيف أسجل الألم؟", "ما أولوية اليوم؟", "كيف أستعد لزيارة مختصة؟"],
            requiresProfessionalCare: false
        )
    }
}
