import SwiftUI
import AppKit

struct BottomBar: View {
    @Binding var selectedFont: WritingFont
    let fontSizeIndex: Int
    let savedFlash: Bool
    let sidebarVisible: Bool
    let timerLabel: String
    let timerRunning: Bool
    let timerStarted: Bool

    let onCycleFont: () -> Void
    let onCycleFontSize: () -> Void
    let onSave: () -> Void
    let onToggleSidebar: () -> Void
    let onCycleTimer: () -> Void
    let onToggleTimer: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            BarButton(label: selectedFont.displayName, action: onCycleFont)
            BarButton(label: "\(Int(fontSizes[fontSizeIndex]))", action: onCycleFontSize)

            Spacer()

            BarButton(label: savedFlash ? "Saved" : "Save", action: onSave)
                .opacity(savedFlash ? 1 : 1) // opacity controlled by caller via disabled state
            BarButton(label: timerLabel, action: onCycleTimer)
            BarButton(
                label: timerRunning ? "Stop" : (timerStarted ? "Reset" : "Start"),
                action: onToggleTimer
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
