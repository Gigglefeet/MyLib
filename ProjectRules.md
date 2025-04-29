# MyLib Project Rules and Conventions

## Parameter Order Conventions

1. **Book Model Parameter Order:**
   - `id`: UUID (auto-generated if not provided)
   - `title`: String (required)
   - `author`: String (required)
   - `notes`: String (optional, defaults to empty string)
   - `rating`: Int (optional, defaults to 0)

   Example: `Book(title: "Book Title", author: "Author Name", notes: "Some notes", rating: 3)`

2. **View Initialization Order:**
   - Always maintain the exact parameter order as defined in the view struct
   - For multi-line function calls, each parameter should be on its own line
   - When adding new parameters, add them at the end of the parameter list unless a specific order is required

## Code Style Conventions

1. **SwiftUI Modifiers:**
   - Group related modifiers together
   - Place view modifiers after content definition
   - Theme-related modifiers (.foregroundColor, .background) should be grouped together

2. **Naming Conventions:**
   - Use Star Wars themed naming for views and functions
   - Action functions should be named descriptively (e.g., moveFromHangarToWishlist)
   - Keep the established naming pattern for similar functions

3. **Color Theme:**
   - Maintain dark mode throughout the app
   - Use cyan for Hangar-related UI elements
   - Keep consistent color usage for similar actions across views

4. **Animation and State Management:**
   - Always assign the result of `withAnimation` when used in a non-view context (e.g. `_ = withAnimation { ... }`)
   - Use `.animation(.none)` for operations that should not be animated (like deletions)
   - Avoid multiple overlapping animations for the same UI elements
   - Defer UI updates after data changes using `DispatchQueue.main.asyncAfter` when needed
   - Ensure all animations have proper completion handling to prevent UI inconsistencies

## File Structure and Syntax

1. **Bracket Matching:**
   - Every opening bracket `{` must have a corresponding closing bracket `}`
   - Avoid extraneous closing brackets at the end of files
   - Use proper indentation to help visually identify bracket pairs
   - When editing complex nested structures, count brackets to ensure proper matching

2. **File Organization:**
   - Each file should contain only the necessary import statements at the top
   - Group related components and extensions within the same file
   - Follow a consistent ordering: imports → struct/class definitions → extensions → previews
   - Separate major sections with MARK comments (e.g., `// MARK: - Helper Views`)

3. **Preview Structure:**
   - All previews should be contained within the `#Preview {}` block
   - Preview helper types should be defined within the preview block
   - Ensure preview code doesn't have extraneous brackets or syntax errors

## Architectural Patterns

1. **Data Flow:**
   - All data mutations should go through ContentView's functions
   - Views receive data as @Binding and actions as function references

2. **Error Handling:**
   - Use print statements for debugging with descriptive prefixes
   - Always include fallback views for error states

3. **Navigation:**
   - Maintain the hyperspace transition effect for navigation
   - Keep consistent navigation title styles

## Editing and Extending Code

1. **Making Changes:**
   - Minimal viable changes only - avoid refactoring existing code unless necessary
   - Preserve existing comments
   - Maintain all Star Wars theming

2. **Adding Features:**
   - Follow existing patterns for similar functionality
   - Match existing confirmation dialog and sheet presentation styles
   - Ensure all new features work with the app's theme 