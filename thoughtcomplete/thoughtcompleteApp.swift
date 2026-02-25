import SwiftUI

@main
struct thoughtcompleteApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            // Remove New Window
            CommandGroup(replacing: .newItem) {}

            // File
            CommandGroup(replacing: .saveItem) {
                Button("Save Thought") {
                    NotificationCenter.default.post(name: .saveThought, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)

                Button("Clear") {
                    NotificationCenter.default.post(name: .clearEditor, object: nil)
                }
                .keyboardShortcut("k", modifiers: .command)

            }

            // View
            CommandGroup(after: .toolbar) {
                Button("Toggle Sidebar") {
                    NotificationCenter.default.post(name: .toggleSidebar, object: nil)
                }
                .keyboardShortcut("b", modifiers: .command)
            }

            // Format
            CommandMenu("Format") {
                Button("Increase Font Size") { appState.increaseFontSize() }
                    .keyboardShortcut("+", modifiers: .command)

                Button("Decrease Font Size") { appState.decreaseFontSize() }
                    .keyboardShortcut("-", modifiers: .command)

                Divider()

                Button("Next Font") {
                    NotificationCenter.default.post(name: .cycleFont, object: nil)
                }
                .keyboardShortcut("t", modifiers: [.command, .option])
            }
        }
        .defaultSize(width: 800, height: 600)

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}

extension Notification.Name {
    static let saveThought  = Notification.Name("saveThought")
    static let clearEditor  = Notification.Name("clearEditor")
    static let toggleSidebar = Notification.Name("toggleSidebar")
    static let cycleFont    = Notification.Name("cycleFont")
}
