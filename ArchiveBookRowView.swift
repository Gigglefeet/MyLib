import SwiftUI

struct ArchiveBookRowView: View {
    // Data needed for the row
    let book: Book
    // Actions passed down
    var setRatingAction: (Book, Int) -> Void
    var markAsUnreadAction: (Book) -> Void // Moves to Wishlist
    var moveToHangarAction: (Book) -> Void // New: Moves to Hangar
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

            // Interactive Lightsaber Ratings (replacing stars)
            HStack {
                ForEach(1...5, id: \.self) { starIndex in
                    LightsaberView(
                        isLit: starIndex <= book.rating,
                        color: LightsaberView.colorForIndex(starIndex),
                        size: .caption
                    )
                    .onTapGesture {
                        withAnimation {
                            let newRating = (starIndex == book.rating) ? 0 : starIndex
                            setRatingAction(book, newRating)
                        }
                    }
                }
            }
        } // End of Row HStack
        .padding(.vertical, 4) // Consistent padding
        .contentShape(Rectangle()) // Ensure entire area is tappable
        .onTapGesture { // Tap row to edit
            self.bookToEdit = book
        }
        .listRowBackground(Color.clear) // Keep row transparent
        // Add context menu for actions (available on long press)
        .contextMenu {
            Button(action: {
                moveToHangarAction(book)
            }) {
                Label("Read Again", systemImage: "airplane.circle.fill")
            }
            
            Button(action: {
                markAsUnreadAction(book)
            }) {
                Label("Move to Wishlist", image: "rebel_logo")
            }
        }
        // Swipe Action: Move to Hangar - Leading Edge (Swipe Right)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
             Button {
                 moveToHangarAction(book)
             } label: {
                 Label("Read Again", systemImage: "airplane.circle.fill") // Keep airplane for Hangar
             }
             .tint(.cyan) // Match Wishlist hangar action color
        }
        // Swipe Action: Move back to Wishlist - Trailing Edge (Swipe Left) - Keep existing
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                markAsUnreadAction(book) // This action moves to Wishlist
            } label: {
                // Using custom Label approach since SF Symbols doesn't have rebel logo
                HStack {
                    Image("rebel_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("Move to Wishlist")
                }
            }
            .tint(.orange)
        }
    }
}

// Preview for the Row - Needs update for new action
#Preview {
    struct RowPreviewWrapper: View {
        @State var sampleBook = Book(title: "Archive Preview", author: "Author Arc", notes: "Archive notes.", rating: 3)
        @State var editingBook: Book? = nil

        func previewSetRating(book: Book, rating: Int) {
            let validatedRating = max(0, min(5, rating))
            sampleBook.rating = validatedRating
             print("PREVIEW ROW ARCHIVE: Set rating for '\(book.title)' to \(validatedRating)")
        }
        func previewMarkUnread(book: Book) { print("PREVIEW ROW ARCHIVE: Move '\(book.title)' to Wishlist") }
        func previewMoveToHangar(book: Book) { print("PREVIEW ROW ARCHIVE: Move '\(book.title)' to Hangar") }


        var body: some View {
            List { // Embed in List for context
                ArchiveBookRowView(
                    book: sampleBook,
                    setRatingAction: previewSetRating,
                    markAsUnreadAction: previewMarkUnread,
                    moveToHangarAction: previewMoveToHangar, // Pass new action
                    bookToEdit: $editingBook // Pass the binding
                )
                 ArchiveBookRowView(
                    book: Book(title: "Another Archive", author: "Other Author", rating: 5),
                    setRatingAction: previewSetRating,
                    markAsUnreadAction: previewMarkUnread,
                    moveToHangarAction: previewMoveToHangar,
                    bookToEdit: $editingBook
                )
            }
            .environment(\.colorScheme, .dark)
            .sheet(item: $editingBook) { bookToEdit in
                 Text("Editing '\(bookToEdit.title)' in Archive Preview")
                     .padding()
            }
        }
    }
    return RowPreviewWrapper()
}

