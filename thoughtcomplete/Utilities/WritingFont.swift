import SwiftUI

enum WritingFont: CaseIterable {
    case serif, sfPro, sansSerif, mono

    var next: WritingFont {
        let all = WritingFont.allCases
        return all[(all.firstIndex(of: self)! + 1) % all.count]
    }

    var displayName: String {
        switch self {
        case .serif:     return "Serif"
        case .sfPro:     return "SF Pro"
        case .sansSerif: return "Sans"
        case .mono:      return "Mono"
        }
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .serif:     return .custom("Georgia", size: size)
        case .sfPro:     return .system(size: size, weight: .regular, design: .default)
        case .sansSerif: return .custom("Helvetica Neue", size: size)
        case .mono:      return .system(size: size, weight: .regular, design: .monospaced)
        }
    }
}

// MARK: - Font Size

let fontSizes: [CGFloat] = [14, 16, 18, 20, 24]

// MARK: - Timer

struct TimerOption {
    let minutes: Int
    var label: String { String(format: "%02d:00", minutes) }
}

let timerOptions: [TimerOption] = [
    TimerOption(minutes: 5),
    TimerOption(minutes: 10),
    TimerOption(minutes: 15),
    TimerOption(minutes: 20),
    TimerOption(minutes: 25),
    TimerOption(minutes: 30),
]
