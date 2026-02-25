import SwiftUI
import AppKit

private let placeholderPrompts = [
    "What's on your mind?",
    "Begin anywhere.",
    "Just start — edit later.",
    "What happened today?",
    "Write the thing you've been avoiding.",
    "What are you thinking about right now?",
    "Pick up where you left off.",
    "Say the thing you haven't said yet.",
    "What's bothering you?",
    "Write badly. That's fine.",
    "Start in the middle.",
    "What do you want to figure out?",
]

struct EditorView: View {
    @Binding var text: String
    let writingFont: WritingFont
    let fontSize: CGFloat
    let completionService: (any CompletionService)?

    @State private var cursorVisible: Bool = true
    @State private var prompt: String = placeholderPrompts.randomElement()!

    var body: some View {
        ZStack(alignment: .topLeading) {
            GhostTextEditor(
                text: $text,
                font: writingFont.nsFont(size: fontSize),
                completionService: completionService
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if text.isEmpty {
                HStack(alignment: .top, spacing: 0) {
                    // Blinking cursor line
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: 2, height: fontSize * 1.3)
                        .foregroundStyle(Color.accentColor)
                        .opacity(cursorVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: cursorVisible)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                cursorVisible = false
                            }
                        }

                    Text(prompt)
                        .font(writingFont.font(size: fontSize))
                        .foregroundStyle(Color(NSColor.placeholderTextColor))
                        .padding(.leading, 3)
                        .transition(.opacity)
                }
                // Match NSTextView textContainerInset: width=60, height=40
                .padding(.leading, 60)
                .padding(.top, 40)
                .allowsHitTesting(false)
                .onAppear {
                    prompt = placeholderPrompts.randomElement()!
                }
            }
        }
    }
}
