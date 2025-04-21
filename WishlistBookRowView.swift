import SwiftUI

struct WishlistBookRowView: View {
    let book: Book
    var markAsReadAction: (Book) -> Void
    @Binding var bookToEdit: Book? // For tapping to edit

    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
                .font(.body).foregroundColor(.white)
            Text(book.author)
                .font(.caption).foregroundColor(.gray)
            
            // Display rating stars if rating > 0
            if book.rating > 0 {
                HStack(spacing: 2) { 
                     ForEach(0..<book.rating, id: \.self) { _ in
                         Image(systemName: "star.fill")
                             .foregroundColor(.yellow)
                             .font(.caption) // Match archive view size
                     }
                 }
                 .padding(.top, 1) // Add a little space above stars
            }
            
            // Add notes preview if notes exist
            if !book.notes.isEmpty {
                Text(book.notes)
                    .font(.footnote) // Slightly smaller font for notes
                    .foregroundColor(.secondary) // Dimmer color
                    .lineLimit(1) // Show only the first line as a preview
                    .padding(.top, 1) // Add a tiny bit of space above notes
            }
        }
        .padding(.bottom, 4) // Add padding for visual separation
        .contentShape(Rectangle()) // Make tappable
        .onTapGesture { // Tap row to edit
            self.bookToEdit = book
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading, allowsFullSwipe: false) { // Mark Read swipe
            Button { markAsReadAction(book) } label: { Label("Mark Read", systemImage: "checkmark.circle.fill") }.tint(.green)
        }
        // We'll add the Divider here in the next phase
    }
}

// Basic Preview for the Row
#Preview {
    struct RowPreviewWrapper: View {
        @State var sampleBook = Book(title: "Wishlist Book", author: "Author W")
        @State var editingBook: Book? = nil

        var body: some View {
            List {
                WishlistBookRowView(
                    book: sampleBook,
                    markAsReadAction: { book in /* print("Preview Row: Mark read \(book.title)") */ },
                    bookToEdit: $editingBook
                )
            }
            .environment(\.colorScheme, .dark)
            .sheet(item: $editingBook) { bookToEdit in
                 Text("Editing \(bookToEdit.title) in Preview")
                     .padding()
            }
        }
    }
    return RowPreviewWrapper()
} 