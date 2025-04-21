import SwiftUI

struct ContentView: View {
    // StateObject to manage the data store
    @StateObject private var dataStore = DataStore()

    // State for presenting the add book sheet
    @State private var showingAddBookSheet = false

    var body: some View {
        NavigationView {
            VStack { // Main content VStack with starfield background
                Spacer()

                // Navigation Link for Wishlist
                NavigationLink {
                     HolocronWishlistView(
                         holocronWishlist: $dataStore.holocronWishlist, // Use DataStore
                         markAsReadAction: markAsRead
                     )
                } label: { // Rebel Logo + Text Label
                    VStack {
                        Image("rebel_logo")
                            .resizable().aspectRatio(contentMode: .fit).frame(width: 100, height: 100)
                        Text("Jedi-Wishlist")
                             .font(.footnote).fontWeight(.bold).foregroundColor(.white)
                             .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                    }
                    .padding()
                }

                // Navigation Link for Archives
                NavigationLink {
                    JediArchivesView(
                        jediArchives: $dataStore.jediArchives, // Use DataStore
                        // Explicitly create a closure with the correct signature
                        setRatingAction: { book, rating in
                            setRating(for: book, to: rating)
                        },
                        markAsUnreadAction: markAsUnread // Pass the new action
                    )
                } label: { // Empire Logo + Text Label
                     VStack {
                        Image("empire_logo")
                            .resizable().aspectRatio(contentMode: .fit).frame(width: 100, height: 100)
                        Text("Empire-Archives")
                             .font(.footnote).fontWeight(.bold).foregroundColor(.white)
                             .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                    }
                     .padding()
                }

                Spacer()

                // Death Star Button to add books
                Button {
                    showingAddBookSheet = true
                } label: {
                    Image("death_star_icon")
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 80, height: 80)
                        .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background( // Starfield background
                 Image("starfield_background")
                    .resizable().scaledToFill().ignoresSafeArea()
            )
            // REMOVED .onAppear
            // REMOVED .onChange modifiers
            .sheet(isPresented: $showingAddBookSheet) { // Sheet to present AddBookView
                 AddBookView { newBook in
                     dataStore.holocronWishlist.append(newBook) // Add to DataStore
                 }
                 .environment(\.colorScheme, .dark)
            }
            .toolbar { // Custom centered title
                ToolbarItem(placement: .principal) {
                    Text("StarBooks Command")
                        .font(.headline).foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                }
            }
        }
         .environment(\.colorScheme, .dark) // Apply dark theme globally
         .navigationViewStyle(.stack) // Use stack navigation
    }

    // REMOVED saveData()
    // REMOVED loadData()

    // --- Core Action Functions (now operate on dataStore) ---
    func markAsRead(book: Book) {
        var bookToMove = book
        bookToMove.rating = 0 // Reset rating when moving
        dataStore.jediArchives.append(bookToMove) // Use DataStore

        if let index = dataStore.holocronWishlist.firstIndex(where: { $0.id == book.id }) { // Use DataStore
            dataStore.holocronWishlist.remove(at: index) // Use DataStore
        } else {
             print("ERROR markAsRead: Failed to find book in wishlist to remove. Rolling back.")
             dataStore.jediArchives.removeAll(where: { $0.id == book.id}) // Use DataStore
        }
    }

    func setRating(for book: Book, to newRating: Int) {
        if let index = dataStore.jediArchives.firstIndex(where: { $0.id == book.id }) { // Use DataStore
            // Ensure rating is within 0-5 range
            let validatedRating = max(0, min(5, newRating))
            dataStore.jediArchives[index].rating = validatedRating // Use DataStore
        } else {
             print("ERROR setRating: Book not found in archives.")
        }
    }

    func markAsUnread(book: Book) {
        print("DEBUG markAsUnread: Moving ID=\(book.id.uuidString) back to wishlist")
        // Find and remove from archives
        if let index = dataStore.jediArchives.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.jediArchives.remove(at: index)
            // Add back to wishlist (rating is preserved from archives)
            dataStore.holocronWishlist.append(bookToMove)
            print("DEBUG markAsUnread: Move successful.")
        } else {
            print("ERROR markAsUnread: Book not found in archives to move back.")
        }
    }
}

// Preview for ContentView - NOTE: May not reflect saved data correctly
#Preview {
    ContentView()
} 
