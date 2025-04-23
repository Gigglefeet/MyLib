import SwiftUI

struct WishlistBookRowView: View {
    let book: Book
    var markAsReadAction: (Book) -> Void
    var moveToHangarAction: (Book) -> Void // New action
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
        .swipeActions(edge: .leading, allowsFullSwipe: false) { // Mark Read swipe (Keep on leading)
            Button { markAsReadAction(book) } label: { 
                // Using custom Label approach since SF Symbols doesn't have empire logo
                HStack {
                    Image("empire_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("Mark Read")
                }
            }.tint(.green)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) { // Add Hangar action to trailing edge
             Button {
                 moveToHangarAction(book)
             } label: {
                 // Using the airplane icon for Hangar
                 Label("Start Reading", systemImage: "airplane.circle.fill")
             }
             .tint(.cyan) // Use a distinct color
        }
    }
}

// Basic Preview for the Row - Needs update for new action
#Preview {
    struct RowPreviewWrapper: View {
        @State var sampleBook = Book(title: "Wishlist Book", author: "Author W", rating: 2, notes: "Some notes") // Added rating/notes
        @State var editingBook: Book? = nil

        func previewMarkRead(book: Book) { print("PREVIEW ROW: Mark Read '\(book.title)'") }
        func previewMoveToHangar(book: Book) { print("PREVIEW ROW: Move '\(book.title)' to Hangar") }

        var body: some View {
            List {
                WishlistBookRowView(
                    book: sampleBook,
                    markAsReadAction: previewMarkRead,
                    moveToHangarAction: previewMoveToHangar, // Provide preview action
                    bookToEdit: $editingBook
                )
                 WishlistBookRowView(
                    book: Book(title: "Another Wishlist", author: "Author X"),
                    markAsReadAction: previewMarkRead,
                     moveToHangarAction: previewMoveToHangar,
                    bookToEdit: $editingBook
                )
            }
            .environment(\.colorScheme, .dark)
            .sheet(item: $editingBook) { bookToEdit in
                 Text("Editing '\(bookToEdit.title)' in Preview")
                     .padding()
            }
        }
    }
    return RowPreviewWrapper()
} 