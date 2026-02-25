import Foundation

protocol CompletionService: Sendable {
    func suggest(for text: String) async throws -> String?
}
