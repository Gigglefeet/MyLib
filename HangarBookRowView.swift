import SwiftUI

struct HangarBookRowView: View {
    // Data & Actions
    let book: Book
    var moveFromHangarToArchives: (Book) -> Void
    var moveFromHangarToWishlist: (Book) -> Void
    var setHangarRating: (Book, Int) -> Void
    @Binding var bookToEdit: Book? // For tapping to edit

    var body: some View {
        HStack { // Main row content
            VStack(alignment: .leading) { // Title, Author, Notes
                Text(book.title)
                    .font(.body).foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 1)
                Text(book.author)
                    .font(.caption).foregroundColor(.gray)
                    .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 1)

                // Notes Preview
                if !book.notes.isEmpty {
                    Text(book.notes)
                        .font(.footnote).foregroundColor(.secondary).lineLimit(1).padding(.top, 1)
                }
            }

            Spacer() // Push rating stars to the right

            // Interactive Rating Stars
            HStack(spacing: 2) { // Reduced spacing for tighter stars
                ForEach(1...5, id: \.self) { starIndex in
                    Image(systemName: starIndex <= book.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption) // Keep size consistent
                        .onTapGesture {
                            // Allow setting rating to 0 by tapping the current rating star
                            let newRating = (starIndex == book.rating) ? 0 : starIndex
                            setHangarRating(book, newRating)
                        }
                }
            }
        } // End of Row HStack
        .padding(.vertical, 4) // Add vertical padding for visual separation
        .contentShape(Rectangle()) // Make entire row tappable for editing
        .onTapGesture {
            self.bookToEdit = book
        }
        .listRowBackground(Color.clear) // Keep background transparent
        // Swipe Action: Mark Finished (Move to Archives) - Leading Edge (Swipe Right)
        .swipeActions(edge: .leading, allowsFullSwipe: true) { // Allow full swipe
            Button {
                moveFromHangarToArchives(book)
            } label: {
                // Using custom Label approach since SF Symbols doesn't have empire logo
                HStack {
                    Image("empire_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("Mark Finished")
                }
            }
            .tint(.green)
        }
        // Replace delete with Move to Wishlist action
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                moveFromHangarToWishlist(book)
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
            .tint(.orange) // Match the color used in other views for wishlist actions
        }
    }
}

// Preview for HangarBookRowView
#Preview {
    struct HangarRowPreviewWrapper: View {
        @State var sampleBook = Book(title: "Row Preview Book", author: "Row Author", notes: "Preview notes...", rating: 3)
        @State var editingBook: Book? = nil

        func previewMoveToArchives(book: Book) {
            print("PREVIEW ROW: Move '\(book.title)' to Archives")
            // In a real scenario, this would modify state, potentially removing the row
        }
        
        func previewMoveToWishlist(book: Book) {
            print("PREVIEW ROW: Move '\(book.title)' to Wishlist")
            // In a real scenario, this would modify state, potentially removing the row
        }

        func previewSetRating(book: Book, rating: Int) {
            let validatedRating = max(0, min(5, rating))
            sampleBook.rating = validatedRating
             print("PREVIEW ROW: Set rating for '\(book.title)' to \(validatedRating)")
        }

        var body: some View {
            List {
                 HangarBookRowView(
                    book: sampleBook,
                    moveFromHangarToArchives: previewMoveToArchives,
                    moveFromHangarToWishlist: previewMoveToWishlist,
                    setHangarRating: previewSetRating,
                    bookToEdit: $editingBook
                )
                 // Add another book for context
                 HangarBookRowView(
                    book: Book(title: "Another Book", author: "Someone Else", rating: 0),
                    moveFromHangarToArchives: previewMoveToArchives,
                    moveFromHangarToWishlist: previewMoveToWishlist,
                    setHangarRating: previewSetRating,
                    bookToEdit: $editingBook
                )
            }
            .environment(\.colorScheme, .dark)
            .sheet(item: $editingBook) { bookToEdit in
                 Text("Editing '\(bookToEdit.title)' in Row Preview")
                     .padding()
            }
        }
    }
    return HangarRowPreviewWrapper()
} 