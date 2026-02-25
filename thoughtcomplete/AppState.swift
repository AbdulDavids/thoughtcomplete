import Foundation
import Observation

enum CompletionProvider: String, CaseIterable, Identifiable {
    case stub             = "Demo (Stub)"
    case foundationModels = "Apple Intelligence"

    var id: String { rawValue }
}

@Observable
class AppState {
    var fontSizeIndex: Int = 2
    let store = ThoughtsStore()

    var autocompleteEnabled: Bool = true {
        didSet { UserDefaults.standard.set(autocompleteEnabled, forKey: "autocompleteEnabled") }
    }

    var selectedProvider: CompletionProvider = .foundationModels {
        didSet { UserDefaults.standard.set(selectedProvider.rawValue, forKey: "completionProvider") }
    }

    var completionService: (any CompletionService)? {
        guard autocompleteEnabled else { return nil }
        switch selectedProvider {
        case .stub:             return StubCompletionService()
        case .foundationModels: return FoundationModelsCompletionService()
        }
    }

    init() {
        // UserDefaults.bool returns false for missing keys, so we need a default-true fallback
        if UserDefaults.standard.object(forKey: "autocompleteEnabled") != nil {
            autocompleteEnabled = UserDefaults.standard.bool(forKey: "autocompleteEnabled")
        }
        if let raw = UserDefaults.standard.string(forKey: "completionProvider"),
           let provider = CompletionProvider(rawValue: raw) {
            selectedProvider = provider
        }
    }

    func increaseFontSize() {
        fontSizeIndex = min(fontSizeIndex + 1, fontSizes.count - 1)
    }

    func decreaseFontSize() {
        fontSizeIndex = max(fontSizeIndex - 1, 0)
    }
}
