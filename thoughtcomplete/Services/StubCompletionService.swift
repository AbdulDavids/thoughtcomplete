import Foundation

struct StubCompletionService: CompletionService {
    private let continuations = [
        " and the light faded slowly into the evening sky.",
        " but nothing could prepare her for what came next.",
        ", which seemed impossible at the time.",
        " — a quiet acknowledgment of everything unsaid.",
        " as if the words themselves had been waiting all along.",
    ]

    func suggest(for text: String) async throws -> String? {
        guard text.count > 10 else { return nil }
        try await Task.sleep(for: .milliseconds(600))
        return continuations.randomElement()
    }
}
