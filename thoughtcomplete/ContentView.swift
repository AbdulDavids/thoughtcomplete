import SwiftUI
import AppKit

struct ContentView: View {
    @Environment(AppState.self) private var appState

    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @State private var text: String = ""
    @State private var selectedFont: WritingFont = .sfPro
    @State private var timerOptionIndex: Int = 2
    @State private var selectedThought: Thought? = nil
    @State private var secondsRemaining: Int = 15 * 60
    @State private var timerRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var savedFlash: Bool = false

    var currentFontSize: CGFloat { fontSizes[appState.fontSizeIndex] }
    var currentTimerOption: TimerOption { timerOptions[timerOptionIndex] }
    var sidebarVisible: Bool { columnVisibility != .detailOnly }
    var timerStarted: Bool { secondsRemaining < currentTimerOption.minutes * 60 }

    var timerLabel: String {
        guard timerRunning || timerStarted else { return currentTimerOption.label }
        return String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selectedThought: $selectedThought)
                .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 280)
        } detail: {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    EditorView(
                        text: $text,
                        writingFont: selectedFont,
                        fontSize: currentFontSize,
                        completionService: appState.completionService
                    )

                    Divider().opacity(0.15)

                    BottomBar(
                        selectedFont: $selectedFont,
                        fontSizeIndex: appState.fontSizeIndex,
                        savedFlash: savedFlash,
                        sidebarVisible: sidebarVisible,
                        timerLabel: timerLabel,
                        timerRunning: timerRunning,
                        timerStarted: timerStarted,
                        hasText: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        onCycleFont:      { selectedFont = selectedFont.next },
                        onCycleFontSize:  { appState.fontSizeIndex = (appState.fontSizeIndex + 1) % fontSizes.count },
                        onSave:           { saveThought() },
                        onClear:          { clearEditor() },
                        onToggleSidebar:  { toggleSidebar() },
                        onCycleTimer:     { cycleTimer() },
                        onToggleTimer:    { toggleTimer() }
                    )
                }
                .background(Color(NSColor.textBackgroundColor))

                if let thought = selectedThought {
                    ThoughtDetailOverlay(thought: thought) {
                        withAnimation(.spring(duration: 0.25)) { selectedThought = nil }
                    } onEdit: {
                        editThought(thought)
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .topLeading)),
                        removal:   .opacity.combined(with: .scale(scale: 0.95, anchor: .topLeading))
                    ))
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 600, minHeight: 400)
        .onReceive(NotificationCenter.default.publisher(for: .saveThought))  { _ in saveThought() }
        .onReceive(NotificationCenter.default.publisher(for: .clearEditor))  { _ in clearEditor() }
        .onReceive(NotificationCenter.default.publisher(for: .toggleSidebar)) { _ in toggleSidebar() }
        .onReceive(NotificationCenter.default.publisher(for: .cycleFont))    { _ in selectedFont = selectedFont.next }
    }

    // MARK: - Sidebar

    private func toggleSidebar() {
        withAnimation {
            if columnVisibility == .detailOnly {
                columnVisibility = .all
            } else {
                columnVisibility = .detailOnly
                selectedThought = nil
            }
        }
    }

    // MARK: - Editor

    private func clearEditor() {
        text = ""
    }

    private func editThought(_ thought: Thought) {
        text = thought.text
        appState.store.delete(thought)
        withAnimation(.spring(duration: 0.25)) {
            selectedThought = nil
            columnVisibility = .detailOnly
        }
    }

    private func saveThought() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        appState.store.save(text)
        text = ""
        savedFlash = true
        if columnVisibility == .detailOnly {
            withAnimation { columnVisibility = .all }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { savedFlash = false }
    }

    // MARK: - Timer

    private func cycleTimer() {
        guard !timerRunning, !timerStarted else { return }
        timerOptionIndex = (timerOptionIndex + 1) % timerOptions.count
        secondsRemaining = currentTimerOption.minutes * 60
    }

    private func toggleTimer() {
        if timerRunning {
            stopTimer()
        } else if timerStarted {
            secondsRemaining = currentTimerOption.minutes * 60
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                stopTimer()
                NSSound.beep()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerRunning = false
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
