import SwiftUI

struct HolocronWishlistView: View {
    @Binding var holocronWishlist: [Book]
    var markAsReadAction: (Book) -> Void
    @State private var bookToEdit: Book?
    
    // AppStorage for persistent sort order
    @AppStorage("wishlistSortOrder") private var sortOrder: WishlistSortOrder = .defaultOrder

    // Computed property for sorted list
    private var sortedWishlist: [Book] {
        switch sortOrder {
        case .defaultOrder:
            // Return original order (from binding)
            // Note: If the original binding isn't guaranteed stable order, this might not be truly "added order"
            // For true added order, DataStore would need to manage it explicitly.
            return holocronWishlist
        case .titleAscending:
            return holocronWishlist.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return holocronWishlist.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }
    }

    var body: some View {
        // Check if the sorted list is empty
        if sortedWishlist.isEmpty {
            // Show empty state view
            VStack {
                Spacer()
                Image(systemName: "book.closed.fill") // Or other appropriate icon
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                Text("Jedi-Wishlist is empty.")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Add some books using the Star Books Button!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack fills space
        } else {
            // Show the list if not empty
            List {
                // Use the computed sortedWishlist
                ForEach(sortedWishlist) { book in
                    // Use the dedicated row view
                    WishlistBookRowView(
                        book: book,
                        markAsReadAction: markAsReadAction,
                        bookToEdit: $bookToEdit // Pass binding for tap-to-edit
                    )
                }
                .onDelete(perform: deleteFromWishlist)
            }
            .background(Color.black) // Set background to black
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            // **** REMOVED .toolbar { ... } MODIFIER ****

            // **** ADD BACK .navigationTitle ****
            .navigationTitle("Jedi-Wishlist")
            // **** END ADD BACK ****

            .environment(\.colorScheme, .dark)
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure nav bar elements are light
            // .navigationBarTitleDisplayMode(.inline) // REMOVED Commented out line
            .sheet(item: $bookToEdit) { bookForItem in // Keep sheet
                if let index = holocronWishlist.firstIndex(where: { $0.id == bookForItem.id }) {
                    // Use the EditBookView that uses NavigationView internally (from previous step)
                    EditBookView(book: $holocronWishlist[index])
                        .environment(\.colorScheme, .dark)
                } else {
                    // Error handling with a fallback view
                    Text("Error: Could not find book to edit")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            // Add Toolbar for Sorting
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Picker bound to the AppStorage variable
                        Picker("Sort Order", selection: $sortOrder) {
                            ForEach(WishlistSortOrder.allCases) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
            }
        }
    }

    // Delete function needs to operate on the original list binding
    private func deleteFromWishlist(at offsets: IndexSet) {
        // Get the IDs of the books to delete based on the *sorted* list's offsets
        let idsToDelete = offsets.map { sortedWishlist[$0].id }
        
        // Remove items from the *original* list based on ID
        holocronWishlist.removeAll { idsToDelete.contains($0.id) }
        
        // print("DEBUG Delete: Attempting at offsets=\(offsets) in sorted list. IDs: \(idsToDelete)") // REMOVED
        // print("DEBUG Delete: Wishlist count now=\(holocronWishlist.count)") // REMOVED
    }
}

// Simplified Preview - Needs update to work well with AppStorage
#Preview {
    // Previewing with AppStorage can be tricky.
    // It might always show default sort or require specific setup.
    // We'll keep it simple for now.
    
    // Need a state variable wrapper for the preview binding
    struct PreviewWrapper: View {
        @State var sampleBooks = [
            Book(title: "B Book", author: "Author P1"),
            Book(title: "A Book", author: "Author P2"),
            Book(title: "C Book", author: "Author P3")
        ]
        
        var body: some View {
            NavigationView {
                HolocronWishlistView(
                    holocronWishlist: $sampleBooks,
                    markAsReadAction: { _ in /* print("Preview MarkRead") */ } // Removed print
                )
                .environment(\.colorScheme, .dark)
                .navigationTitle("Preview Title")
            }
        }
    }
    
    // Clear AppStorage for preview consistency if needed (use cautiously)
    // UserDefaults.standard.removeObject(forKey: "wishlistSortOrder")
    
    return PreviewWrapper()
}
