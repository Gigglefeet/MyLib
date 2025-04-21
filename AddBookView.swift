import SwiftUI

struct AddBookView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var notes: String = "" // Keep notes state
    // Removed: @State private var rating: Int = 0

    var onSave: (Book) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Book Title", text: $title)
                TextField("Author", text: $author)

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                // Removed: Section for Rating (Stepper)
            }
            .navigationTitle("Add New Holocron")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    // Create book without rating (uses default 0)
                    let newBook = Book(title: title, author: author, notes: notes) // Removed rating
                    onSave(newBook)
                    dismiss()
                }
                .disabled(title.isEmpty || author.isEmpty)
            )
             .environment(\.colorScheme, .dark)
        }
    }
}

// Preview
#Preview { AddBookView(onSave: { _ in }) .environment(\.colorScheme, .dark) }