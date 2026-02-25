import SwiftUI
import AppKit

struct EditorView: View {
    @Binding var text: String
    let font: Font

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(font)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 60)
                .padding(.vertical, 40)

            if text.isEmpty {
                Text("Start writing...")
                    .font(font)
                    .foregroundColor(Color(NSColor.placeholderTextColor))
                    .padding(.horizontal, 65)
                    .padding(.top, 48)
                    .allowsHitTesting(false)
            }
        }
    }
}
