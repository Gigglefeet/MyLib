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

                // Top Row: Wishlist and Archives side-by-side
                HStack {
                    Spacer() // Center the HStack contents

                    // Navigation Link for Wishlist
                    NavigationLink {
                         HolocronWishlistView(
                             holocronWishlist: $dataStore.holocronWishlist, // Use DataStore
                             markAsReadAction: markAsRead,
                             moveToHangarAction: moveToHangarFromWishlist // Pass new action
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

                    Spacer() // Add space between the two top buttons

                    // Navigation Link for Archives
                    NavigationLink {
                        JediArchivesView(
                            jediArchives: $dataStore.jediArchives, // Use DataStore
                            setRatingAction: setRating,
                            markAsUnreadAction: markAsUnread, // Keep existing action
                            moveToHangarAction: moveToHangarFromArchives // Pass new action
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

                    Spacer() // Center the HStack contents
                } // End of Top HStack

                Spacer() // Push Hangar button down

                // Middle Row: Hangar button
                NavigationLink {
                    // Destination will be HangarView (created in Phase 4)
                    // Pass all required bindings and actions
                    HangarView(
                        inTheHangar: $dataStore.inTheHangar,
                        moveFromHangarToArchives: moveFromHangarToArchives,
                        setHangarRating: setHangarRating,
                        reorderHangar: reorderHangar,
                        moveToHangarFromWishlist: moveToHangarFromWishlist,
                        moveFromHangarToWishlist: moveFromHangarToWishlist,
                        wishlist: $dataStore.holocronWishlist
                    )
                } label: {
                    VStack {
                        // Placeholder for Millennium Falcon
                        Image(systemName: "airplane.circle.fill") // Placeholder Icon
                             .resizable().aspectRatio(contentMode: .fit).frame(width: 100, height: 100)
                             .foregroundColor(.cyan) // Give it some color
                        Text("In The Hangar")
                            .font(.footnote).fontWeight(.bold).foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                    }
                    .padding()
                }

                Spacer() // Push Add button down

                // Bottom Row: Death Star Button to add books
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
        bookToMove.rating = 0 // Reset rating when moving TO archives
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
            // ** NOTE: This goes to WISHLIST as per clarification **
            dataStore.holocronWishlist.append(bookToMove)
            print("DEBUG markAsUnread: Move successful.")
        } else {
            print("ERROR markAsUnread: Book not found in archives to move back.")
        }
    }

    // --- Hangar Action Functions ---

    func moveToHangarFromWishlist(book: Book) {
        if let index = dataStore.holocronWishlist.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.holocronWishlist.remove(at: index)
            dataStore.inTheHangar.append(bookToMove)
        } else {
            print("ERROR moveToHangarFromWishlist: Book not found in wishlist.")
        }
    }

    func moveToHangarFromArchives(book: Book) {
        if let index = dataStore.jediArchives.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.jediArchives.remove(at: index)
            // Rating is preserved when moving from Archives to Hangar
            dataStore.inTheHangar.append(bookToMove)
        } else {
            print("ERROR moveToHangarFromArchives: Book not found in archives.")
        }
    }

    func moveFromHangarToArchives(book: Book) {
        if let index = dataStore.inTheHangar.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.inTheHangar.remove(at: index)
            // Rating is preserved when moving from Hangar to Archives
            dataStore.jediArchives.append(bookToMove)
        } else {
            print("ERROR moveFromHangarToArchives: Book not found in hangar.")
        }
    }

    func setHangarRating(for book: Book, to newRating: Int) {
        if let index = dataStore.inTheHangar.firstIndex(where: { $0.id == book.id }) {
            let validatedRating = max(0, min(5, newRating))
            dataStore.inTheHangar[index].rating = validatedRating
        } else {
            print("ERROR setHangarRating: Book not found in hangar.")
        }
    }

    func reorderHangar(from source: IndexSet, to destination: Int) {
        dataStore.inTheHangar.move(fromOffsets: source, toOffset: destination)
    }

    func moveFromHangarToWishlist(book: Book) {
        if let index = dataStore.inTheHangar.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.inTheHangar.remove(at: index)
            // Rating is preserved when moving from Hangar to Wishlist
            dataStore.holocronWishlist.append(bookToMove)
        } else {
            print("ERROR moveFromHangarToWishlist: Book not found in hangar.")
        }
    }
}

// Preview for ContentView - NOTE: May not reflect saved data correctly
#Preview {
    ContentView()
} 
