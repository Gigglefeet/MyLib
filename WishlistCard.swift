import SwiftUI

struct WishlistCard: View {
    let book: Book
    let moveToHangarAction: (Book) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(book.author)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
            
            // Display rating if it exists
            if book.rating > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<book.rating, id: \.self) { index in
                        LightsaberView(
                            isLit: true,
                            color: LightsaberView.colorForIndex(index + 1),
                            size: .caption
                        )
                    }
                }
                .padding(.top, 1)
            }
            
            // Show notes preview if they exist
            if !book.notes.isEmpty {
                Text(book.notes)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.top, 1)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .listRowBackground(Color.clear)
    }
}

#Preview {
    List {
        WishlistCard(
            book: Book(title: "Card Preview", author: "Card Author", notes: "Card notes", rating: 3),
            moveToHangarAction: { book in 
                print("PREVIEW: Move \(book.title) to hangar")
            }
        )
    }
    .environment(\.colorScheme, .dark)
} 