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
    let hasText: Bool

    let onCycleFont: () -> Void
    let onCycleFontSize: () -> Void
    let onSave: () -> Void
    let onClear: () -> Void
    let onToggleSidebar: () -> Void
    let onCycleTimer: () -> Void
    let onToggleTimer: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            BarButton(label: selectedFont.displayName, action: onCycleFont)
            BarButton(label: "\(Int(fontSizes[fontSizeIndex]))", action: onCycleFontSize)

            if hasText {
                BarButton(label: "Clear", action: onClear)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            Spacer()

            BarButton(label: savedFlash ? "Saved" : "Save", action: onSave)
                .opacity(hasText ? 1 : 0.3)
            BarButton(label: sidebarVisible ? "Hide" : "Thoughts", action: onToggleSidebar)
            BarButton(label: timerLabel, action: onCycleTimer)
            BarButton(
                label: timerRunning ? "Stop" : (timerStarted ? "Reset" : "Start"),
                action: onToggleTimer
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(Color(NSColor.windowBackgroundColor))
        .animation(.easeInOut(duration: 0.15), value: hasText)
    }
}
