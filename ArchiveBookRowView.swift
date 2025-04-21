import SwiftUI

struct ArchiveBookRowView: View {
    // Data needed for the row
    let book: Book
    // Actions passed down
    var setRatingAction: (Book, Int) -> Void
    var markAsUnreadAction: (Book) -> Void
    // Binding to control the edit sheet presentation in the parent
    @Binding var bookToEdit: Book?

    var body: some View {
        HStack { // Main row HStack
            VStack(alignment: .leading) { // Title and Author
                Text(book.title)
                    .font(.body).foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 1)
                Text(book.author)
                    .font(.caption).foregroundColor(.gray)
                    .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 1)
                // Add notes preview if notes exist
                if !book.notes.isEmpty {
                    Text(book.notes)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }
            Spacer() // Push rating display to the right

            // Interactive Rating Stars
            HStack {
                ForEach(1...5, id: \.self) { starIndex in
                    Image(systemName: starIndex <= book.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption)
                        .onTapGesture {
                            let newRating = (starIndex == book.rating) ? 0 : starIndex
                            setRatingAction(book, newRating)
                        }
                }
            }
        } // End of Row HStack
        .padding(.bottom, 4) // Add padding for visual separation
        .contentShape(Rectangle()) // Ensure entire area is tappable
        .onTapGesture { // Tap row to edit
            self.bookToEdit = book
        }
        .listRowBackground(Color.clear) // Keep row transparent
        // Add Swipe Action for moving back to wishlist
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button { // Removed 'role: .normal'
                markAsUnreadAction(book)
            } label: {
                Label("Move to Wishlist", systemImage: "arrow.uturn.backward.circle.fill")
            }
            .tint(.orange)
        }
    }
}

// Optional: Basic Preview for the Row itself
#Preview {
    // Need a wrapper to provide state/bindings for preview
    struct RowPreviewWrapper: View {
        // Use @State for mutable preview data
        @State var sampleBook = Book(title: "Preview Book", author: "Author P", rating: 3)
        @State var editingBook: Book? = nil

        var body: some View {
            List { // Embed in List for context
                ArchiveBookRowView(
                    book: sampleBook,
                    setRatingAction: { book, rating in
                        // Simulate update for preview state
                        if let b = sampleBook as Book?, b.id == book.id {
                           sampleBook.rating = rating
                        }
                    },
                    markAsUnreadAction: { book in
                    },
                    bookToEdit: $editingBook // Pass the binding
                )
            }
            .environment(\.colorScheme, .dark)
            // Add a sheet to the wrapper for testing the row's tap gesture
            .sheet(item: $editingBook) { bookToEdit in
                 Text("Editing \(bookToEdit.title) in Preview")
                     .padding()
            }
        }
    }
    return RowPreviewWrapper()
}
