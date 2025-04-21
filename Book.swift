import Foundation // Keep Foundation for UUID
// No SwiftUI needed here unless Book itself uses SwiftUI types directly

// Book struct definition
struct Book: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var author: String
    var notes: String = ""
    var rating: Int = 0 // Should be 0-5

    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }
}
