import XCTest
@testable import WarifNative

final class AssistantSafetyPolicyTests: XCTestCase {
    func testUrgentArabicLanguageReturnsEscalationResponse() {
        let response = AssistantSafetyPolicy.urgentResponse(for: "لدي نزيف شديد ولا يتوقف")

        XCTAssertNotNil(response)
        XCTAssertEqual(response?.requiresProfessionalCare, true)
        XCTAssertTrue(response?.suggestedPrompts.isEmpty == true)
    }

    func testOrdinaryQuestionDoesNotTriggerEmergencyResponse() {
        XCTAssertNil(AssistantSafetyPolicy.urgentResponse(for: "كيف أسجل الألم اليوم؟"))
    }
}
