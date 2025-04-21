import Foundation

// Enum for Wishlist Sorting Options
enum WishlistSortOrder: String, CaseIterable, Identifiable {
    case defaultOrder = "Added Order" // Or perhaps Title Ascending as default?
    case titleAscending = "Title (A-Z)"
    case titleDescending = "Title (Z-A)"

    var id: String { self.rawValue }
}

// Enum for Archives Sorting Options
enum ArchivesSortOrder: String, CaseIterable, Identifiable {
    case defaultOrder = "Added Order" // Or perhaps Rating Descending as default?
    case titleAscending = "Title (A-Z)"
    case titleDescending = "Title (Z-A)"
    case ratingAscending = "Rating (Low-High)"
    case ratingDescending = "Rating (High-Low)"

    var id: String { self.rawValue }
}
