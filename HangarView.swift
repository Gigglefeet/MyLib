import SwiftUI

struct HangarView: View {
    @Binding var inTheHangar: [Book]
    // Actions from ContentView
    var moveFromHangarToArchives: (Book) -> Void
    var setHangarRating: (Book, Int) -> Void
    var reorderHangar: (IndexSet, Int) -> Void
    var moveToHangarFromWishlist: (Book) -> Void // Action to move book *to* hangar
    var moveFromHangarToWishlist: (Book) -> Void // New action to move book back to wishlist
    var deleteFromHangar: (IndexSet) -> Void // Function to delete books
    var deleteBookFromHangar: (Book) -> Void // New function to delete by book ID

    // Binding for wishlist selection modal
    @Binding var wishlist: [Book] // Need the wishlist to show in the modal

    // State for modal presentation
    @State private var showingSelectWishlistSheet = false
    // State for edit sheet presentation
    @State private var bookToEdit: Book?
    
    // AppStorage for persistent sort order
    @AppStorage("hangarSortOrder") private var sortOrder: HangarSortOrder = .defaultOrder

    // Filtered wishlist (non-empty titles/authors) for the selection sheet
    private var selectableWishlist: [Book] {
        wishlist.filter { !$0.title.isEmpty && !$0.author.isEmpty }
    }
    
    // Computed property for sorted list
    private var sortedHangar: [Book] {
        switch sortOrder {
        case .defaultOrder:
            return inTheHangar // Return original order
        case .titleAscending:
            return inTheHangar.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return inTheHangar.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .ratingAscending:
            // Sort by rating low-to-high, then title ascending for ties
            return inTheHangar.sorted { 
                if $0.rating != $1.rating {
                    return $0.rating < $1.rating
                } else {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
        case .ratingDescending:
            // Sort by rating high-to-low, then title ascending for ties
            return inTheHangar.sorted { 
                if $0.rating != $1.rating {
                    return $0.rating > $1.rating
                } else {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
        }
    }

    var body: some View {
        ZStack {
            // Check if the hangar list is empty
            if inTheHangar.isEmpty && !showingSelectWishlistSheet { // Avoid flicker when sheet shows
                ZStack {
                    // Add cyan-tinted starfield for Hangar theme
                    StarfieldView(starCount: 120, twinkleAnimation: true, parallaxEnabled: true)
                        .opacity(0.9)
                        .colorMultiply(Color.cyan.opacity(0.2)) // Give slight cyan tint
                    
                    EmptyHangarView(
                        showingSelectWishlistSheet: $showingSelectWishlistSheet,
                        selectableWishlist: selectableWishlist
                    )
                }
            } else {
                ZStack {
                    // Add cyan-tinted starfield for Hangar theme
                    StarfieldView(starCount: 120, twinkleAnimation: true, parallaxEnabled: true)
                        .opacity(0.9)
                        .colorMultiply(Color.cyan.opacity(0.2)) // Give slight cyan tint
                    
                    PopulatedHangarView(
                        sortedHangar: sortedHangar,
                        originalHangarData: $inTheHangar,
                        moveFromHangarToArchives: moveFromHangarToArchives,
                        moveFromHangarToWishlist: moveFromHangarToWishlist,
                        setHangarRating: setHangarRating,
                        deleteFromHangar: deleteFromHangar,
                        deleteBookFromHangar: deleteBookFromHangar,
                        bookToEdit: $bookToEdit,
                        sortOrder: $sortOrder,
                        reorderHangar: reorderHangar,
                        showingSelectWishlistSheet: $showingSelectWishlistSheet,
                        selectableWishlist: selectableWishlist
                    )
                }
            }
        }
        // Apply sheets and theme to the container view (remains outside)
        .sheet(isPresented: $showingSelectWishlistSheet) {
           // Simple Wishlist Selection Sheet
           NavigationView { // Embed in NavView for title/button
                ZStack {
                    // Add a starfield behind the list
                    StarfieldView(starCount: 50)
                    
                    List {
                        ForEach(selectableWishlist) { book in
                            Button {
                                // Move selected book and dismiss
                                moveToHangarFromWishlist(book)
                                showingSelectWishlistSheet = false
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(book.title).foregroundColor(.primary) // Ensure text is visible
                                    Text(book.author).font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
                .navigationTitle("Select from Wishlist")
                .navigationBarItems(leading: Button("Cancel") { showingSelectWishlistSheet = false })
                .environment(\.colorScheme, .dark) // Match theme
            }
        }
        .sheet(item: $bookToEdit) { book in // Sheet for editing
            // Find the index in the *hangar* binding array
            if let index = inTheHangar.firstIndex(where: { $0.id == book.id }) {
                EditBookView(book: $inTheHangar[index]) // Pass binding
                    .environment(\.colorScheme, .dark)
            } else {
                Text("Error: Could not find book to edit in hangar list.")
                    .foregroundColor(.red).padding()
            }
        }
        .environment(\.colorScheme, .dark) // Apply dark theme
    }
}

// MARK: - Helper Views
struct EmptyHangarView: View {
    @Binding var showingSelectWishlistSheet: Bool
    let selectableWishlist: [Book]
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "airplane.circle.fill") // Placeholder Icon
                .font(.largeTitle)
                .foregroundColor(.cyan)
                .padding(.bottom, 5)
            Text("Hangar is empty.")
                .font(.headline)
                .foregroundColor(.white)
            Text("Add books currently being read from the Wishlist or Archives.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear) // Make background transparent
        .navigationTitle("In The Hangar")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSelectWishlistSheet = true
                } label: {
                    Label("Add Book", systemImage: "plus.circle.fill")
                }
                .disabled(selectableWishlist.isEmpty)
            }
        }
    }
}

struct PopulatedHangarView: View {
    let sortedHangar: [Book]
    // Add binding to the original unsorted array
    @Binding var originalHangarData: [Book]
    var moveFromHangarToArchives: (Book) -> Void
    var moveFromHangarToWishlist: (Book) -> Void
    var setHangarRating: (Book, Int) -> Void
    var deleteFromHangar: (IndexSet) -> Void // Add delete function
    var deleteBookFromHangar: (Book) -> Void // New function to delete by ID
    @Binding var bookToEdit: Book?
    @Binding var sortOrder: HangarSortOrder
    var reorderHangar: (IndexSet, Int) -> Void
    @Binding var showingSelectWishlistSheet: Bool
    let selectableWishlist: [Book]
    
    // Proper SwiftUI way to handle edit mode
    @State private var editMode: EditMode = .inactive
    
    // Add state to force view refresh
    @State private var refreshID = UUID()
    
    // Wrapper to handle book deletion with refresh
    private func handleBookDeletion(book: Book) {
        // Call the actual deletion function
        deleteBookFromHangar(book)
        
        // Force a refresh of the view after deletion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            refreshID = UUID()
        }
    }
    
    // Add a mapping function to handle sorted deletion
    private func handleSortedDeletion(offsets: IndexSet) {
        // When list is sorted, we need to map the visual indexes to actual data indexes
        if sortOrder != .defaultOrder {
            // Map the sorted indices to actual Book objects
            let sortedBooks = sortedHangar
            let toDelete = offsets.map { sortedBooks[$0] }
            
            // Since we're using ForEach with unique IDs, we can map based on object identity
            let originalBooks = originalHangarData // Access the unsorted original data
            
            // Find the original indices in the data source by ID
            var originalIndices = IndexSet()
            for bookToDelete in toDelete {
                if let index = originalBooks.firstIndex(where: { $0.id == bookToDelete.id }) {
                    originalIndices.insert(index)
                }
            }
            
            print("DEBUG: Mapped sorted indices \(offsets) to original indices \(originalIndices)")
            withAnimation(.none) {
                deleteFromHangar(originalIndices)
            }
        } else {
            // No sorting, just use the indices directly
            withAnimation(.none) {
                deleteFromHangar(offsets)
            }
        }
        
        // Force a refresh of the view after deletion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            refreshID = UUID()
        }
    }
    
    var body: some View {
        List {
            ForEach(sortedHangar) { book in
                HangarBookRowView(
                    book: book,
                    moveFromHangarToArchives: moveFromHangarToArchives,
                    moveFromHangarToWishlist: moveFromHangarToWishlist,
                    setHangarRating: setHangarRating,
                    deleteAction: handleBookDeletion, // Use our wrapper function
                    bookToEdit: $bookToEdit,
                    isEditMode: false // Always use normal mode since we removed the edit button
                )
            }
            .onMove(perform: sortOrder == .defaultOrder ? reorderHangar : nil)
            .onDelete(perform: handleSortedDeletion) // Map the indices if needed
        }
        // Use a binding to the EditMode state but we'll never activate it
        .environment(\.editMode, $editMode)
        .scrollContentBackground(.hidden) // Keep list background transparent
        .listStyle(.plain) // Use plain style for better transparency
        .background(Color.clear) // Make sure it's transparent
        .id(refreshID) // Force the list to re-render when the refreshID changes
        // Remove the bottom toolbar since there's no edit mode
        .navigationTitle("In The Hangar")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort Order", selection: $sortOrder) {
                        ForEach(HangarSortOrder.allCases) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                        .foregroundColor(.cyan) // Match theme
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSelectWishlistSheet = true
                } label: {
                    Label("Add Book", systemImage: "plus.circle.fill")
                        .foregroundColor(.cyan) // Match theme
                }
                .disabled(selectableWishlist.isEmpty)
            }
        }
    }
}

// Basic Preview - Requires significant setup due to bindings and actions
#Preview {
    // Need a wrapper view to manage state for the preview
    struct HangarPreviewWrapper: View {
        @State private var previewHangar: [Book] = [
            Book(title: "Hangar Book 1", author: "Author H1", notes: "", rating: 4),
            Book(title: "Hangar Book 2", author: "Author H2", notes: "", rating: 0),
            Book(title: "Hangar Book 3", author: "Author H3", notes: "Long note preview...", rating: 5)
        ]
        @State private var previewWishlist: [Book] = [
             Book(title: "Wishlist Book 1", author: "Author W1"),
             Book(title: "Wishlist Book 2", author: "Author W2")
        ]
        @State private var previewArchives: [Book] = [] // For move action target

        func previewMoveToArchives(book: Book) {
            if let index = previewHangar.firstIndex(where: { $0.id == book.id }) {
                let movedBook = previewHangar.remove(at: index)
                previewArchives.append(movedBook)
                print("PREVIEW: Moved '\(movedBook.title)' to Archives")
            }
        }
        
        func previewMoveToWishlist(book: Book) {
            if let index = previewHangar.firstIndex(where: { $0.id == book.id }) {
                let movedBook = previewHangar.remove(at: index)
                previewWishlist.append(movedBook)
                print("PREVIEW: Moved '\(movedBook.title)' to Wishlist")
            }
        }

        func previewSetRating(book: Book, rating: Int) {
            if let index = previewHangar.firstIndex(where: { $0.id == book.id }) {
                 let validatedRating = max(0, min(5, rating))
                previewHangar[index].rating = validatedRating
                print("PREVIEW: Set rating for '\(previewHangar[index].title)' to \(validatedRating)")
            }
        }

        func previewReorder(from source: IndexSet, to destination: Int) {
             previewHangar.move(fromOffsets: source, toOffset: destination)
             print("PREVIEW: Reordered hangar list")
        }

        func previewMoveToHangar(book: Book) {
            if let index = previewWishlist.firstIndex(where: {$0.id == book.id}) {
                let movedBook = previewWishlist.remove(at: index)
                previewHangar.append(movedBook)
                print("PREVIEW: Moved '\(movedBook.title)' from Wishlist to Hangar")
            }
        }

        func previewDeleteFromHangar(at offsets: IndexSet) {
            previewHangar.remove(atOffsets: offsets)
            print("PREVIEW: Deleted book(s) from Hangar")
        }
        
        func previewDeleteBookFromHangar(book: Book) {
            if let index = previewHangar.firstIndex(where: { $0.id == book.id }) {
                previewHangar.remove(at: index)
                print("PREVIEW: Deleted book '\(book.title)' from Hangar")
            }
        }

        var body: some View {
            NavigationView {
                HangarView(
                    inTheHangar: $previewHangar,
                    moveFromHangarToArchives: previewMoveToArchives,
                    setHangarRating: previewSetRating,
                    reorderHangar: previewReorder,
                    moveToHangarFromWishlist: previewMoveToHangar,
                    moveFromHangarToWishlist: previewMoveToWishlist,
                    deleteFromHangar: previewDeleteFromHangar,
                    deleteBookFromHangar: previewDeleteBookFromHangar,
                    wishlist: $previewWishlist
                )
            }
            .environment(\.colorScheme, .dark)
        }
    }

    return HangarPreviewWrapper()
} 