import SwiftUI
import AppKit

struct BarButton: View {
    let label: String
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(hovered ? Color(NSColor.labelColor) : Color(NSColor.secondaryLabelColor))
                .animation(.easeInOut(duration: 0.1), value: hovered)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
