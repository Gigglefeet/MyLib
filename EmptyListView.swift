import SwiftUI

struct EmptyListView: View {
    let message: String
    let imageName: String
    
    var body: some View {
        ZStack {
            // Add animated starfield background
            StarfieldView(starCount: 80, twinkleAnimation: true, parallaxEnabled: true)
                .opacity(0.7) // Slightly dimmed for less distraction
            
            VStack {
                Spacer()
                
                if imageName == "holocron" {
                    // Use rebel_logo for Holocron wishlist
                    Image("rebel_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 5)
                } else {
                    // Fallback to a system icon
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Add books using the Death Star button on the main screen.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    VStack {
        EmptyListView(message: "This list is empty", imageName: "holocron")
    }
    .environment(\.colorScheme, .dark)
} 