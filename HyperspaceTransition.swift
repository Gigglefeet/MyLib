import SwiftUI

// Extension to add custom view modifier for hyperspace effect
extension AnyTransition {
    static var hyperspace: AnyTransition {
        let insertion = AnyTransition.modifier(
            active: HyperspaceEffect(progress: 1),
            identity: HyperspaceEffect(progress: 0)
        )
        
        let removal = AnyTransition.modifier(
            active: HyperspaceEffect(progress: 0),
            identity: HyperspaceEffect(progress: 1)
        )
        
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

// A view modifier that creates the hyperspace jump effect
struct HyperspaceEffect: ViewModifier {
    // 0 = normal, 1 = fully in hyperspace
    let progress: CGFloat
    
    // Animation properties
    @State private var streakOpacity: Double = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Original content with scaling and blur
                content
                    .scaleEffect(1 + (progress * 0.2))
                    .blur(radius: progress * 5)
                    .opacity(1.0 - (progress * 0.5))
                
                // Hyperspace streaks
                ForEach(0..<20, id: \.self) { _ in
                    HyperspaceStreak(
                        width: CGFloat.random(in: 1...3),
                        length: CGFloat.random(in: 20...100) * progress,
                        angle: CGFloat.random(in: 0...360),
                        offset: CGFloat.random(in: 0...geometry.size.width/2) * progress
                    )
                    .opacity(streakOpacity * Double(progress))
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.2)) {
                    streakOpacity = 1.0
                }
            }
        }
    }
}

// Individual hyperspace streak
struct HyperspaceStreak: View {
    let width: CGFloat
    let length: CGFloat
    let angle: CGFloat
    let offset: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: length, height: width)
            .rotationEffect(.degrees(Double(angle)))
            .offset(
                x: offset * cos(angle * .pi / 180),
                y: offset * sin(angle * .pi / 180)
            )
            .blur(radius: 1)
    }
}

// Extension for NavigationLink to use hyperspace transition
extension View {
    func hyperspaceTransition() -> some View {
        self.transition(.hyperspace.combined(with: .opacity).animation(.easeInOut(duration: 0.5)))
    }
}

// Preview
#Preview {
    HyperspaceTransitionDemo()
}

// Demo view for transition preview
struct HyperspaceTransitionDemo: View {
    @State private var showDestination = false
    
    var body: some View {
        ZStack {
            StarfieldView(starCount: 100)
            
            if showDestination {
                VStack {
                    Text("Destination")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Button("Go Back") {
                        withAnimation {
                            showDestination = false
                        }
                    }
                    .foregroundColor(.yellow)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .hyperspaceTransition()
            } else {
                VStack {
                    Text("Origin")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Button("Jump to Hyperspace") {
                        withAnimation {
                            showDestination = true
                        }
                    }
                    .foregroundColor(.yellow)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .hyperspaceTransition()
            }
        }
    }
} 