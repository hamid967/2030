import Foundation

/// Client for a server-owned AI gateway. The gateway is responsible for model
/// credentials, authentication, rate limits, moderation, retention, and audit.
struct AssistantGateway: WarifAssistantProviding {
    private let endpoint: URL?
    private let fallback: LocalWarifAssistant

    init(bundle: Bundle = .main, fallback: LocalWarifAssistant = LocalWarifAssistant()) {
        endpoint = bundle.object(forInfoDictionaryKey: "WARIF_AI_GATEWAY_URL")
            .flatMap { $0 as? String }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .flatMap { value in
                guard let url = URL(string: value), url.scheme?.lowercased() == "https" else { return nil }
                return url
            }
        self.fallback = fallback
    }

    func reply(to request: AssistantRequest, allowCloudProcessing: Bool) async throws -> AssistantResponse {
        guard allowCloudProcessing, let endpoint else {
            return try await fallback.reply(to: request, allowCloudProcessing: false)
        }
        if let urgent = AssistantSafetyPolicy.urgentResponse(for: request.message) { return urgent }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.timeoutInterval = 20
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            return try await fallback.reply(to: request, allowCloudProcessing: false)
        }
        return try JSONDecoder().decode(AssistantResponse.self, from: data)
    }
}

struct MockWarifAssistant: WarifAssistantProviding {
    func reply(to request: AssistantRequest, allowCloudProcessing: Bool) async throws -> AssistantResponse {
        try await LocalWarifAssistant().reply(to: request, allowCloudProcessing: false)
    }
}
