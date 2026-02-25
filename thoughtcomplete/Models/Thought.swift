import Foundation

struct Thought: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var text: String
    var date: Date = Date()

    var preview: String {
        let line = text
            .components(separatedBy: .newlines)
            .first { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? ""
        return line.isEmpty ? "Empty thought" : line
    }

    var formattedDate: String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
