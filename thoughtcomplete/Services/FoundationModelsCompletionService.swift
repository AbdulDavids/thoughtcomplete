import Foundation
import FoundationModels

struct FoundationModelsCompletionService: CompletionService {
    func suggest(for text: String) async throws -> String? {
        guard text.count > 10 else { return nil }
        guard SystemLanguageModel.default.isAvailable else { return nil }

        let session = LanguageModelSession(
            instructions: """
            You are an inline text completion engine. \
            Your output is appended directly to the user's text — never reply, explain, or add commentary. \
            Output only the raw continuation: the next few words or one clause that naturally follows. \
            No preamble. No acknowledgement. No punctuation beyond what flows naturally. \
            If the text ends mid-sentence, continue the sentence. \
            If it ends at a sentence boundary, start the next one. \
            Keep it under 15 words.
            """
        )
        let prompt = "\(text)"
        let options = GenerationOptions(temperature: 0.3, maximumResponseTokens: 40)
        do {
            let response = try await session.respond(to: prompt, options: options)
            return stitch(text, response.content)
        } catch LanguageModelSession.GenerationError.guardrailViolation,
                LanguageModelSession.GenerationError.refusal {
            return "[can't complete this]"
        }
    }

    /// Stitches existing text and completion with correct spacing.
    ///
    /// - Mid-word (existing ends with a letter/digit): butt completion directly, strip any leading space the model added.
    /// - After whitespace: strip any extra leading whitespace from the completion (space already present).
    /// - After punctuation/other with no space: add one space before the completion.
    private func stitch(_ existing: String, _ completion: String) -> String {
        guard !completion.isEmpty else { return completion }
        let last = existing.last
        let trailingSpace = last?.isWhitespace ?? false
        let midWord       = last?.isLetter == true || last?.isNumber == true

        if midWord {
            // Completing a word — drop any leading space the model prepended
            return String(completion.drop(while: { $0.isWhitespace }))
        } else if trailingSpace {
            // Already have a space — drop any duplicate leading whitespace
            return String(completion.drop(while: { $0.isWhitespace }))
        } else {
            // After punctuation etc. — need a space before the new word
            if completion.first?.isWhitespace == true {
                return completion
            }
            return " " + completion
        }
    }
}
