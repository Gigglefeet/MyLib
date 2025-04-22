import SwiftUI

struct JediArchivesView: View {
    @Binding var jediArchives: [Book]
    // Action to set the rating (passed from ContentView)
    var setRatingAction: (Book, Int) -> Void
    // Action to move book back to wishlist (passed from ContentView)
    var markAsUnreadAction: (Book) -> Void
    var moveToHangarAction: (Book) -> Void
    
    // AppStorage for persistent sort order
    @AppStorage("archivesSortOrder") private var sortOrder: ArchivesSortOrder = .defaultOrder
    
    // State for presenting the edit sheet
    @State private var bookToEdit: Book?
    
    // Computed property for sorted list
    private var sortedArchives: [Book] {
        switch sortOrder {
        case .defaultOrder:
            return jediArchives
        case .titleAscending:
            return jediArchives.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return jediArchives.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .ratingAscending:
            // Sort by rating low-to-high, then title ascending for ties
            return jediArchives.sorted { 
                if $0.rating != $1.rating {
                    return $0.rating < $1.rating
                } else {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
        case .ratingDescending:
            // Sort by rating high-to-low, then title ascending for ties
             return jediArchives.sorted { 
                if $0.rating != $1.rating {
                    return $0.rating > $1.rating
                } else {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
        }
    }

    var body: some View {
        // Check if the sorted list is empty
        if sortedArchives.isEmpty {
            // Show empty state view
            VStack {
                Spacer()
                Image(systemName: "archivebox.fill") // Or other appropriate icon
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                Text("Empire-Archives are empty.")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Mark books as read from the Wishlist or finish reading from the Hangar to add them here.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // Show the list if not empty
            List {
                // Use the computed sortedArchives
                ForEach(sortedArchives) { book in
                    // Use the dedicated row view
                    ArchiveBookRowView(
                        book: book,
                        setRatingAction: setRatingAction,
                        markAsUnreadAction: markAsUnreadAction,
                        moveToHangarAction: moveToHangarAction,
                        bookToEdit: $bookToEdit // Pass the binding for sheet presentation
                    )
                }
                .onDelete(perform: deleteFromArchives) // Existing delete (swipe left / leading edge)
            }
             .environment(\.colorScheme, .dark) // Apply dark theme
             .scrollContentBackground(.hidden) // Keep list background transparent for dark theme
             .toolbar { // Custom centered title with background
                 ToolbarItem(placement: .principal) {
                     Text("Empire-Archives")
                         .font(.headline).foregroundColor(.white)
                         .padding(.horizontal, 12).padding(.vertical, 6)
                         .background(Capsule().fill(Color.black.opacity(0.6)))
                 }
                 // Add ToolbarItem for Sorting Menu
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort Order", selection: $sortOrder) {
                            ForEach(ArchivesSortOrder.allCases) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
             }
             // Add sheet modifier for editing
             .sheet(item: $bookToEdit) { bookToEdit in
                 // Find the index of the book in the *original* binding array
                 if let index = jediArchives.firstIndex(where: { $0.id == bookToEdit.id }) {
                     EditBookView(book: $jediArchives[index]) // Pass the binding
                         .environment(\.colorScheme, .dark)
                 } else {
                     // Fallback if book not found (shouldn't happen in normal use)
                     Text("Error: Could not find book to edit in original list.")
                         .foregroundColor(.red)
                         .padding()
                 }
             }
        }
    }

    // Delete function needs to operate on the original list binding
    private func deleteFromArchives(at offsets: IndexSet) {
        // Get the IDs of the books to delete based on the *sorted* list's offsets
        let idsToDelete = offsets.map { sortedArchives[$0].id }
        
        // Remove items from the *original* list based on ID
        jediArchives.removeAll { idsToDelete.contains($0.id) }
    }
}

// Updated Preview - Needs update for AppStorage/Sorting
#Preview {
    // Previewing with AppStorage can be tricky.
    struct PreviewWrapper: View {
         @State var previewList = [
            Book(title: "B Book Archive", author: "Author C", rating: 3),
            Book(title: "A Book Archive", author: "Author D", rating: 5),
            Book(title: "C Book Archive", author: "Author E", rating: 1, notes: "Archived notes")
        ]

        func previewSetRating(book: Book, newRating: Int) {
            if let index = previewList.firstIndex(where: { $0.id == book.id }) {
                previewList[index].rating = max(0, min(5, newRating))
                 print("PREVIEW: Set rating for '\(previewList[index].title)' to \(previewList[index].rating)")
            }
        }
        func previewMarkUnread(book: Book) {
            previewList.removeAll(where: { $0.id == book.id })
            print("PREVIEW: Moved '\(book.title)' to Wishlist (Simulated)")
        }
         func previewMoveToHangar(book: Book) {
            previewList.removeAll(where: { $0.id == book.id })
            print("PREVIEW: Moved '\(book.title)' to Hangar (Simulated)")
         }

        var body: some View {
            NavigationView {
                // Provide the binding and dummy actions for the preview
                JediArchivesView(
                    jediArchives: $previewList, 
                    setRatingAction: previewSetRating,
                    markAsUnreadAction: previewMarkUnread,
                    moveToHangarAction: previewMoveToHangar
                )
                 .environment(\.colorScheme, .dark)
            }
        }
    }
    
    // Clear AppStorage for preview consistency if needed
    // UserDefaults.standard.removeObject(forKey: "archivesSortOrder")

    return PreviewWrapper()
}