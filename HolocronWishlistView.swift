import SwiftUI

// Fixed signature issues:
// 1. Changed SortOption to WishlistSortOrder
// 2. Updated function signatures to use (Book) instead of (UUID, Bool) or (Int)
// 3. Added handleSortedDeletion to properly handle sorted list deletion

struct HolocronWishlistView: View {
    @Binding var holocronWishlist: [Book]
    let markAsReadAction: (Book) -> Void
    let moveToHangarAction: (Book) -> Void
    let deleteAction: (IndexSet) -> Void
    let reorderWishlist: (IndexSet, Int) -> Void
    
    @State private var selectedSortOption: WishlistSortOrder = .defaultOrder
    @State private var editMode: EditMode = .inactive
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
        if holocronWishlist.isEmpty {
            EmptyListView(message: "Your Holocron Wishlist is Empty", imageName: "holocron")
        } else {
            List {
                ForEach(sortedWishlist) { book in
                    NavigationLink(destination: BookDetailView(book: book, markAsReadAction: markAsReadAction)) {
                        WishlistBookRowView(
                            book: book,
                            markAsReadAction: markAsReadAction,
                            moveToHangarAction: moveToHangarAction,
                            bookToEdit: $bookToEdit
                        )
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = holocronWishlist.firstIndex(where: { $0.id == book.id }) {
                                deleteAction(IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: reorderWishlist)
                .onDelete(perform: handleSortedDeletion)
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sortOrder) {
                            ForEach(WishlistSortOrder.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .sheet(item: $bookToEdit) { bookToEdit in
                if let index = holocronWishlist.firstIndex(where: { $0.id == bookToEdit.id }) {
                    EditBookView(book: $holocronWishlist[index])
                        .environment(\.colorScheme, .dark)
                }
            }
        }
    }

    private func handleSortedDeletion(offsets: IndexSet) {
        if sortOrder != .defaultOrder {
            let idsToDelete = offsets.map { sortedWishlist[$0].id }
            
            holocronWishlist.removeAll { idsToDelete.contains($0.id) }
        } else {
            deleteAction(offsets)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var sampleBooks = [
            Book(title: "B Book", author: "Author P1"),
            Book(title: "A Book", author: "Author P2"),
            Book(title: "C Book", author: "Author P3")
        ]

        func previewMarkRead(book: Book) { print("PREVIEW: Mark Read '\(book.title)'") }
        func previewMoveToHangar(book: Book) { print("PREVIEW: Move '\(book.title)' to Hangar") }
        func previewDelete(at offsets: IndexSet) { 
            sampleBooks.remove(atOffsets: offsets)
            print("PREVIEW: Delete books at offsets \(offsets)")
        }


        var body: some View {
            NavigationView {
                HolocronWishlistView(
                    holocronWishlist: $sampleBooks,
                    markAsReadAction: previewMarkRead,
                    moveToHangarAction: previewMoveToHangar,
                    deleteAction: previewDelete,
                    reorderWishlist: { _, _ in }
                )
                .environment(\.colorScheme, .dark)
            }
        }
    }
    return PreviewWrapper()
}
