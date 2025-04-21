import SwiftUI

struct EditBookView: View {
    @Binding var book: Book
    @Environment(\.dismiss) var dismiss

    // Local temporary state for editing fields
    @State private var editableTitle: String = ""
    @State private var editableAuthor: String = ""
    @State private var editableNotes: String = ""

    var body: some View {
        // **** REVERTED TO USING NavigationView ****
        NavigationView {
            Form {
                TextField("Book Title", text: $editableTitle)
                TextField("Author", text: $editableAuthor)
                    .onChange(of: editableAuthor) {
                        // print("DEBUG Edit: editableAuthor state changed to: \(editableAuthor)") // REMOVED
                    }

                Section(header: Text("Notes")) {
                    TextEditor(text: $editableNotes)
                        .frame(height: 150)
                }
            }
            // **** REVERTED TO navigationBarItems ****
            .navigationBarItems(
                leading: Button("Cancel") {
                    // print("DEBUG Edit: Cancelled for ID=\(book.id.uuidString)") // REMOVED
                    dismiss()
                },
                trailing: Button("Save") {
                    // print("DEBUG Save: Attempting for ID=\(book.id.uuidString)") // REMOVED
                    // print("DEBUG Save:   Editable Title=\(editableTitle)") // REMOVED
                    // print("DEBUG Save:   Editable Author=\(editableAuthor)") // REMOVED

                    // Apply changes
                    book.title = editableTitle
                    book.author = editableAuthor
                    book.notes = editableNotes

                    // print("DEBUG Save:   *After Assign* book.title=\(book.title)") // REMOVED
                    // print("DEBUG Save:   *After Assign* book.author=\(book.author)") // REMOVED

                    dismiss()
                }
                // Disable Save button if title or author is empty
                .disabled(editableTitle.isEmpty || editableAuthor.isEmpty)
            )
            // **** END REVERT ****
            .navigationTitle("Edit Holocron")
             // .navigationBarTitleDisplayMode(.inline) // REMOVED Commented out line

            .environment(\.colorScheme, .dark) // Apply theme
            .onAppear { // Load initial data
                // print("DEBUG Edit: Appeared for ID=\(book.id.uuidString)") // REMOVED
                self.editableTitle = book.title
                self.editableAuthor = book.author
                self.editableNotes = book.notes
                // print("DEBUG Edit:   Initial editableTitle: \(editableTitle)") // REMOVED
                // print("DEBUG Edit:   Initial editableAuthor: \(editableAuthor)") // REMOVED
            }
        }
        // **** END REVERT ****
    }
}

// Preview setup (No longer needs wrapper as NavView is internal again)
#Preview {
    struct PreviewWrapper: View {
        @State var previewBook = Book(title: "Sample Edit", author: "Test Author", notes: "Some existing notes.")
        var body: some View {
            EditBookView(book: $previewBook)
             .environment(\.colorScheme, .dark)
        }
    }
    return PreviewWrapper()
}