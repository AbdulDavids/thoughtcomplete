import SwiftUI
import AppKit

// MARK: - Ghost marker attribute key

private let ghostAttributeKey = NSAttributedString.Key("com.thoughtcomplete.ghost")

// MARK: - GhostTextEditor

struct GhostTextEditor: NSViewRepresentable {
    @Binding var text: String
    let font: NSFont
    let completionService: (any CompletionService)?

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, completionService: completionService)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let textView = GhostAwareTextView()
        textView.coordinator = context.coordinator
        context.coordinator.textView = textView

        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.drawsBackground = false
        textView.font = font
        textView.textColor = NSColor.labelColor
        textView.delegate = context.coordinator
        textView.autoresizingMask = [.width]
        textView.textContainerInset = NSSize(width: 60, height: 40)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? GhostAwareTextView else { return }
        let coordinator = context.coordinator

        // Update font if it changed
        if textView.font != font {
            coordinator.clearGhost(in: textView)
            textView.font = font
        }

        // Only sync text if binding differs from real (non-ghost) content
        let realText = coordinator.realText(in: textView)
        if realText != text {
            coordinator.clearGhost(in: textView)
            textView.string = text
        }
    }
}

// MARK: - GhostAwareTextView

final class GhostAwareTextView: NSTextView {
    weak var coordinator: GhostTextEditor.Coordinator?

    override func keyDown(with event: NSEvent) {
        guard let coordinator else {
            super.keyDown(with: event)
            return
        }

        if coordinator.ghostRange != nil {
            // Tab (48) or Right arrow (124) → accept ghost (unless it's a refusal)
            if event.keyCode == 48 || event.keyCode == 124 {
                guard !coordinator.ghostIsRefusal(in: self) else {
                    coordinator.clearGhost(in: self)
                    super.keyDown(with: event)
                    return
                }
                coordinator.acceptGhost(in: self)
                return
            }
            // Any other key → clear ghost first, then process normally
            coordinator.clearGhost(in: self)
        }

        super.keyDown(with: event)
    }
}

// MARK: - Coordinator

extension GhostTextEditor {
    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        private var textBinding: Binding<String>
        private let completionService: (any CompletionService)?
        private(set) var ghostRange: NSRange?
        private var debounceTask: Task<Void, Never>?
        weak var textView: GhostAwareTextView?

        init(text: Binding<String>, completionService: (any CompletionService)?) {
            self.textBinding = text
            self.completionService = completionService
        }

        // MARK: - Ghost helpers

        /// Returns the text storage content stripped of any ghost suffix.
        func realText(in textView: NSTextView) -> String {
            guard let ghostRange else { return textView.string }
            let storage = textView.textStorage!
            let fullString = storage.string
            if ghostRange.location <= fullString.count {
                return String(fullString.prefix(ghostRange.location))
            }
            return fullString
        }

        /// Appends ghost string to text storage, outside undo registration.
        func applyGhost(_ suggestion: String, in textView: NSTextView) {
            guard let storage = textView.textStorage else { return }
            clearGhost(in: textView)

            let insertLocation = storage.length
            let ghostStr = NSAttributedString(
                string: suggestion,
                attributes: [
                    .foregroundColor: NSColor.placeholderTextColor,
                    .font: textView.font ?? NSFont.systemFont(ofSize: 16),
                    ghostAttributeKey: true
                ]
            )

            textView.undoManager?.disableUndoRegistration()
            storage.append(ghostStr)
            textView.undoManager?.enableUndoRegistration()

            ghostRange = NSRange(location: insertLocation, length: suggestion.count)
        }

        func ghostIsRefusal(in textView: NSTextView) -> Bool {
            guard let range = ghostRange, let storage = textView.textStorage else { return false }
            guard range.location + range.length <= storage.length else { return false }
            let ghostText = (storage.string as NSString).substring(with: range)
            return ghostText.hasPrefix("[")
        }

        /// Removes ghost text from storage without affecting undo stack.
        func clearGhost(in textView: NSTextView) {
            guard let range = ghostRange, let storage = textView.textStorage else {
                ghostRange = nil
                return
            }

            let storageLength = storage.length
            guard range.location + range.length <= storageLength else {
                ghostRange = nil
                return
            }

            textView.undoManager?.disableUndoRegistration()
            storage.deleteCharacters(in: range)
            textView.undoManager?.enableUndoRegistration()

            ghostRange = nil
        }

        /// Promotes ghost to real text by recoloring and syncing the binding.
        func acceptGhost(in textView: NSTextView) {
            guard let range = ghostRange, let storage = textView.textStorage else { return }

            let storageLength = storage.length
            guard range.location + range.length <= storageLength else {
                ghostRange = nil
                return
            }

            // Remove ghost marker attribute and recolor to normal text
            storage.removeAttribute(ghostAttributeKey, range: range)
            storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: range)
            if let font = textView.font {
                storage.addAttribute(.font, value: font, range: range)
            }

            ghostRange = nil

            // Move cursor to end
            let end = storage.length
            textView.setSelectedRange(NSRange(location: end, length: 0))

            // Sync binding
            textBinding.wrappedValue = textView.string
        }

        // MARK: - NSTextViewDelegate

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            clearGhost(in: textView)

            let current = textView.string
            textBinding.wrappedValue = current

            scheduleCompletion(for: current, in: textView)
        }

        // MARK: - Debounced completion

        private func scheduleCompletion(for text: String, in textView: NSTextView) {
            debounceTask?.cancel()
            guard let service = completionService else { return }
            debounceTask = Task { [weak self] in
                guard let self else { return }
                do {
                    try await Task.sleep(for: .milliseconds(400))
                    guard !Task.isCancelled else { return }
                    let suggestion = try await service.suggest(for: text)
                    guard !Task.isCancelled, let suggestion else { return }
                    // Back on MainActor (class is @MainActor)
                    self.applyGhost(suggestion, in: textView)
                } catch {
                    // Cancelled or service error — ignore silently
                }
            }
        }
    }
}
