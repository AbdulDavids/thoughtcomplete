import Observation

@Observable
class AppState {
    var fontSizeIndex: Int = 2
    let store = ThoughtsStore()

    func increaseFontSize() {
        fontSizeIndex = min(fontSizeIndex + 1, fontSizes.count - 1)
    }

    func decreaseFontSize() {
        fontSizeIndex = max(fontSizeIndex - 1, 0)
    }
}
