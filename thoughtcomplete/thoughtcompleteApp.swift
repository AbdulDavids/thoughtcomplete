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
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Format") {
                Button("Increase Font Size") {
                    appState.increaseFontSize()
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Decrease Font Size") {
                    appState.decreaseFontSize()
                }
                .keyboardShortcut("-", modifiers: .command)
            }
        }
        .defaultSize(width: 800, height: 600)
    }
}
