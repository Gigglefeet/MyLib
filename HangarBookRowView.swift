import SwiftUI

// MARK: - Row View Definition
struct HangarBookRowView: View {
    // Data & Actions
    let book: Book
    var moveFromHangarToArchives: (Book) -> Void
    var moveFromHangarToWishlist: (Book) -> Void
    var setHangarRating: (Book, Int) -> Void
    var deleteAction: ((Book) -> Void)? // Optional delete action
    @Binding var bookToEdit: Book? // For tapping to edit
    // Edit mode state
    var isEditMode: Bool = false
    
    // State for delete confirmation
    @State private var showingDeleteAlert = false

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
            
            // Only show delete button when in edit mode
            if isEditMode && deleteAction != nil {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 8)
            }

            // Interactive Lightsaber Ratings (replacing stars)
            HStack(spacing: 2) { // Reduced spacing for tighter lightsabers
                ForEach(1...5, id: \.self) { starIndex in
                    LightsaberView(
                        isLit: starIndex <= book.rating,
                        color: LightsaberView.colorForIndex(starIndex),
                        size: .caption
                    )
                    .onTapGesture {
                        // Allow setting rating to 0 by tapping the current rating star
                        withAnimation {
                            let newRating = (starIndex == book.rating) ? 0 : starIndex
                            setHangarRating(book, newRating)
                        }
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
        // Context menu for all actions (available on long press)
        .contextMenu {
            Button(action: {
                moveFromHangarToArchives(book)
            }) {
                Label("Mark Finished", image: "empire_logo")
            }
            
            Button(action: {
                moveFromHangarToWishlist(book)
            }) {
                Label("Move to Wishlist", image: "rebel_logo")
            }
            
            if deleteAction != nil {
                Divider()
                Button(role: .destructive, action: {
                    showingDeleteAlert = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        // Use regular alert for deletion confirmation
        .alert("Delete Book", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                print("DEBUG: HangarBookRowView - Delete confirmed for book: \(book.title)")
                if let action = deleteAction {
                    action(book)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(book.title)'?")
        }
    }
}

// MARK: - Preview
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
        
        func previewDeleteBook(book: Book) {
            print("PREVIEW ROW: Delete '\(book.title)'")
        }

        var body: some View {
            List {
                 // Standard mode
                 HangarBookRowView(
                    book: sampleBook,
                    moveFromHangarToArchives: previewMoveToArchives,
                    moveFromHangarToWishlist: previewMoveToWishlist,
                    setHangarRating: previewSetRating,
                    deleteAction: previewDeleteBook,
                    bookToEdit: $editingBook,
                    isEditMode: false
                )
                 // Edit mode
                 HangarBookRowView(
                    book: Book(title: "Edit Mode Book", author: "Someone Else", notes: "In edit mode", rating: 2),
                    moveFromHangarToArchives: previewMoveToArchives,
                    moveFromHangarToWishlist: previewMoveToWishlist,
                    setHangarRating: previewSetRating,
                    deleteAction: previewDeleteBook,
                    bookToEdit: $editingBook,
                    isEditMode: true
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
