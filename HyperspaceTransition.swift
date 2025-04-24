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

// Extension for NavigationLink to use hyperspace transition (for custom navigation scenarios)
extension View {
    func hyperspaceTransition() -> some View {
        self.transition(.hyperspace.combined(with: .opacity).animation(.easeInOut(duration: 0.5)))
    }
    
    // For use with NavigationView - simplified version that won't interfere with navigation
    func navigationHyperspaceEffect() -> some View {
        self.modifier(SafeHyperspaceModifier())
    }
}

// A safer modifier that doesn't add UIViewControllerRepresentable which might interfere with navigation
struct SafeHyperspaceModifier: ViewModifier {
    @State private var isActive = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Short delay then animate in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isActive = true
                    }
                }
            }
            .modifier(HyperspaceFlashEffect(isActive: isActive))
    }
}

// A simpler effect that adds a quick flash of streaks around the edges
struct HyperspaceFlashEffect: ViewModifier {
    let isActive: Bool
    
    @State private var flashOpacity: Double = 0
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // Only show effect briefly when appearing
            if isActive {
                GeometryReader { geometry in
                    ZStack {
                        // Edge flash
                        VStack {
                            HStack {
                                ForEach(0..<15) { _ in
                                    Rectangle()
                                        .fill(Color.white.opacity(0.7))
                                        .frame(width: CGFloat.random(in: 1...3), 
                                               height: CGFloat.random(in: 30...100))
                                        .blur(radius: 2)
                                        .rotationEffect(.degrees(90))
                                        .offset(y: -CGFloat.random(in: 0...20))
                                }
                            }
                            .frame(width: geometry.size.width)
                            
                            Spacer()
                            
                            HStack {
                                ForEach(0..<15) { _ in
                                    Rectangle()
                                        .fill(Color.white.opacity(0.7))
                                        .frame(width: CGFloat.random(in: 1...3), 
                                               height: CGFloat.random(in: 30...100))
                                        .blur(radius: 2)
                                        .rotationEffect(.degrees(90))
                                        .offset(y: CGFloat.random(in: 0...20))
                                }
                            }
                            .frame(width: geometry.size.width)
                        }
                        .frame(height: geometry.size.height)
                        
                        // Side flashes
                        HStack {
                            VStack {
                                ForEach(0..<15) { _ in
                                    Rectangle()
                                        .fill(Color.white.opacity(0.7))
                                        .frame(width: CGFloat.random(in: 1...3), 
                                               height: CGFloat.random(in: 30...100))
                                        .blur(radius: 2)
                                        .offset(x: -CGFloat.random(in: 0...20))
                                }
                            }
                            .frame(height: geometry.size.height)
                            
                            Spacer()
                            
                            VStack {
                                ForEach(0..<15) { _ in
                                    Rectangle()
                                        .fill(Color.white.opacity(0.7))
                                        .frame(width: CGFloat.random(in: 1...3), 
                                               height: CGFloat.random(in: 30...100))
                                        .blur(radius: 2)
                                        .offset(x: CGFloat.random(in: 0...20))
                                }
                            }
                            .frame(height: geometry.size.height)
                        }
                        .frame(width: geometry.size.width)
                    }
                    .opacity(flashOpacity)
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 0.1)) {
                        flashOpacity = 1.0
                    }
                    
                    // Automatically remove the effect
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            flashOpacity = 0
                        }
                    }
                }
            }
        }
    }
}

// KEEPING THE ORIGINAL COORDINATOR FOR REFERENCE BUT IT'S NOT USED ANYMORE
// Coordinator to handle navigation transitions
struct HyperspaceTransitionCoordinator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Monitor navigation transactions
        if let coordinator = uiViewController.navigationController?.transitionCoordinator {
            coordinator.animate(alongsideTransition: { context in
                // Could trigger custom animations here
            })
        }
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
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showDestination = false
                        }
                    }
                    .foregroundColor(.yellow)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.hyperspace)
            } else {
                VStack {
                    Text("Origin")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Button("Jump to Hyperspace") {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showDestination = true
                        }
                    }
                    .foregroundColor(.yellow)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
} 