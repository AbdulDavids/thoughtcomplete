import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    @Binding var selectedThought: Thought?

    var body: some View {
        Group {
            if appState.store.thoughts.isEmpty {
                ContentUnavailableView(
                    "No thoughts yet",
                    systemImage: "text.bubble",
                    description: Text("Save something from the editor.")
                )
            } else {
                List(appState.store.thoughts, selection: $selectedThought) { thought in
                    ThoughtRow(thought: thought)
                        .tag(thought)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    if selectedThought?.id == thought.id { selectedThought = nil }
                                    appState.store.delete(thought)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .listStyle(.sidebar)
            }
        }
        .navigationTitle("Thoughts")
    }
}
