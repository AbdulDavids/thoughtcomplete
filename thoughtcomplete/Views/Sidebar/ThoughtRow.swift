import SwiftUI

struct ThoughtRow: View {
    let thought: Thought

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(thought.preview)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(thought.formattedDate)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
