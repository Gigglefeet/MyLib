import Foundation
import Combine // Needed for ObservableObject and @Published

class DataStore: ObservableObject {
    @Published var holocronWishlist: [Book] = [] {
        didSet {
            // Automatically save whenever the list changes
            saveData()
        }
    }
    @Published var jediArchives: [Book] = [] {
        didSet {
            // Automatically save whenever the list changes
            saveData()
        }
    }
    // Add new list for books being currently read
    @Published var inTheHangar: [Book] = [] {
        didSet {
            saveData()
        }
    }

    // UserDefaults keys remain private here
    private let wishlistKey = "holocronWishlist"
    private let archivesKey = "jediArchives"
    private let hangarKey = "inTheHangar" // New key for the hangar list

    // Initializer to load data when the store is created
    init() {
        loadData()
    }

    // --- Data Persistence Functions (now correctly inside the class) ---
    func saveData() {
        let encoder = JSONEncoder()
        
        // Save Wishlist with error handling
        do {
            let encodedWishlist = try encoder.encode(holocronWishlist)
            UserDefaults.standard.set(encodedWishlist, forKey: wishlistKey)
        } catch {
            print("ERROR DataStore saveData: Failed to encode/save wishlist. Error: \(error.localizedDescription)")
        }

        // Save Archives with error handling
        do {
            let encodedArchives = try encoder.encode(jediArchives)
            UserDefaults.standard.set(encodedArchives, forKey: archivesKey)
        } catch {
            print("ERROR DataStore saveData: Failed to encode/save archives. Error: \(error.localizedDescription)")
        }

        // Save Hangar list with error handling
        do {
            let encodedHangar = try encoder.encode(inTheHangar)
            UserDefaults.standard.set(encodedHangar, forKey: hangarKey)
        } catch {
             print("ERROR DataStore saveData: Failed to encode/save hangar list. Error: \(error.localizedDescription)")
        }
    }

    func loadData() {
        let decoder = JSONDecoder()

        // Load Wishlist with error handling
        if let savedWishlist = UserDefaults.standard.data(forKey: wishlistKey) {
            do {
                let decodedWishlist = try decoder.decode([Book].self, from: savedWishlist)
                self.holocronWishlist = decodedWishlist
            } catch {
                print("ERROR DataStore loadData: Failed to decode wishlist. Error: \(error.localizedDescription)")
                self.holocronWishlist = [] // Reset on failure
            }
        } else {
            self.holocronWishlist = [] // Ensure it's initialized
        }

        // Load Archives with error handling
        if let savedArchives = UserDefaults.standard.data(forKey: archivesKey) {
             do {
                 let decodedArchives = try decoder.decode([Book].self, from: savedArchives)
                 self.jediArchives = decodedArchives
             } catch {
                 print("ERROR DataStore loadData: Failed to decode archives. Error: \(error.localizedDescription)")
                 self.jediArchives = [] // Reset on failure
             }
        } else {
            self.jediArchives = [] // Ensure it's initialized
        }

        // Load Hangar list with error handling
        if let savedHangar = UserDefaults.standard.data(forKey: hangarKey) {
             do {
                 let decodedHangar = try decoder.decode([Book].self, from: savedHangar)
                 self.inTheHangar = decodedHangar
             } catch {
                 print("ERROR DataStore loadData: Failed to decode hangar list. Error: \(error.localizedDescription)")
                 self.inTheHangar = [] // Reset on failure
             }
        } else {
            self.inTheHangar = [] // Ensure it's initialized
        }
    }
} 
