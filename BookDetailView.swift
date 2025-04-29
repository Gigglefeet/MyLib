import SwiftUI

struct BookDetailView: View {
    let book: Book
    let markAsReadAction: (Book) -> Void
    
    @State private var showingMarkReadAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with title and author
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(book.author)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                
                // Rating section if the book has a rating
                if book.rating > 0 {
                    Divider()
                    
                    HStack {
                        Text("Rating:")
                            .font(.headline)
                        
                        Spacer()
                        
                        // Display rating lightsabers
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                LightsaberView(
                                    isLit: index <= book.rating,
                                    color: LightsaberView.colorForIndex(index),
                                    size: .body
                                )
                            }
                        }
                    }
                }
                
                // Notes section if the book has notes
                if !book.notes.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes:")
                            .font(.headline)
                        
                        Text(book.notes)
                            .font(.body)
                            .padding(12)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer(minLength: 20)
                
                // Mark as Read button
                Button(action: {
                    showingMarkReadAlert = true
                }) {
                    HStack {
                        Image("empire_logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Mark as Read")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(
            StarfieldView(starCount: 60, twinkleAnimation: true)
                .opacity(0.7)
                .edgesIgnoringSafeArea(.all)
        )
        .alert("Mark as Read?", isPresented: $showingMarkReadAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Mark Read") {
                markAsReadAction(book)
            }
        } message: {
            Text("'\(book.title)' will be moved to the Archives.")
        }
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    NavigationView {
        BookDetailView(
            book: Book(
                title: "Preview Detail Book",
                author: "Detail Author",
                notes: "These are some detailed notes for the preview book. It should be long enough to demonstrate text wrapping and proper display.",
                rating: 4
            ),
            markAsReadAction: { book in
                print("PREVIEW: Marked \(book.title) as read")
            }
        )
    }
    .environment(\.colorScheme, .dark)
} 