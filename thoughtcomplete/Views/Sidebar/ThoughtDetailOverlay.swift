import SwiftUI

struct ThoughtDetailOverlay: View {
    let thought: Thought
    let onDismiss: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(thought.formattedDate)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Edit") {
                    onEdit()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.trailing, 8)

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().opacity(0.25)

            ScrollView(.vertical, showsIndicators: false) {
                Text(thought.text)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .textSelection(.enabled)
            }
        }
        .frame(width: 300, height: 240)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
    }
}
