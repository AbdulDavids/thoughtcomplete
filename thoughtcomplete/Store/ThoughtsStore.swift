import Foundation
import Observation

@Observable
class ThoughtsStore {
    private(set) var thoughts: [Thought] = []

    private let storageKey = "saved_thoughts"

    init() {
        load()
    }

    func save(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        thoughts.insert(Thought(text: text), at: 0)
        persist()
    }

    func delete(_ thought: Thought) {
        thoughts.removeAll { $0.id == thought.id }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(thoughts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Thought].self, from: data)
        else { return }
        thoughts = decoded
    }
}
