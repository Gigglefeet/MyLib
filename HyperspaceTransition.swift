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
    
    // For use with NavigationView - full cinematic hyperspace effect
    func navigationHyperspaceEffect() -> some View {
        self.modifier(CinematicHyperspaceModifier())
    }
}

// A more cinematic hyperspace effect that covers the whole screen
struct CinematicHyperspaceModifier: ViewModifier {
    @State private var showHyperspace = false
    @State private var showDestination = false
    
    func body(content: Content) -> some View {
        ZStack {
            // Only show actual destination content after hyperspace effect
            if showDestination {
                content
                    .transition(.opacity)
            }
            
            // Full-screen hyperspace effect
            if showHyperspace {
                HyperspaceAnimationView()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Start hyperspace sequence
            withAnimation(.easeIn(duration: 0.2)) {
                showHyperspace = true
            }
            
            // After 1 second, show the destination
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showHyperspace = false
                    showDestination = true
                }
            }
        }
    }
}

// Animated hyperspace view
struct HyperspaceAnimationView: View {
    @State private var animationProgress: Double = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            HyperspaceStarfield(progress: animationProgress)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
}

// Full-screen cinematic hyperspace view with real-time animation
struct HyperspaceStarfield: View {
    let progress: Double
    @State private var stars: [HyperStar] = []
    
    // Random initial positions
    private let starCount = 200
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep space background
                Color.black
                
                // Central glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.white, .white.opacity(0)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 30 + 50 * progress
                        )
                    )
                    .frame(width: 60 + 100 * progress)
                    .opacity(max(0, 1 - progress))
                    .blur(radius: 5)
                
                // Dynamic star streaks
                ForEach(0..<stars.count, id: \.self) { index in
                    if index < stars.count {
                        let star = stars[index]
                        StarStreakView(
                            startPoint: star.startPoint,
                            endPoint: calculateEndPoint(
                                start: star.startPoint, 
                                angle: star.angle, 
                                progress: progress, 
                                speed: star.speed,
                                size: geometry.size
                            ),
                            width: star.width,
                            color: star.color,
                            progress: progress
                        )
                    }
                }
            }
            .onAppear {
                initializeStars(size: geometry.size)
            }
        }
    }
    
    private func initializeStars(size: CGSize) {
        stars = (0..<starCount).map { _ in
            let angleRad = CGFloat.random(in: 0..<2*CGFloat.pi)
            let startRadius = CGFloat.random(in: 0...20)
            let startPoint = CGPoint(
                x: size.width/2 + cos(angleRad) * startRadius,
                y: size.height/2 + sin(angleRad) * startRadius
            )
            
            return HyperStar(
                startPoint: startPoint,
                angle: angleRad,
                width: CGFloat.random(in: 1...3),
                speed: CGFloat.random(in: 0.7...1.5),
                color: starColor()
            )
        }
    }
    
    private func calculateEndPoint(start: CGPoint, angle: CGFloat, progress: Double, speed: CGFloat, size: CGSize) -> CGPoint {
        let maxDistance = max(size.width, size.height) * 1.5
        let distance = maxDistance * progress * speed
        
        return CGPoint(
            x: start.x + cos(angle) * distance,
            y: start.y + sin(angle) * distance
        )
    }
    
    private func starColor() -> Color {
        let colors: [Color] = [
            .white, .white, .white, 
            .blue.opacity(0.9),
            .cyan.opacity(0.8)
        ]
        return colors.randomElement()!
    }
}

// Data structure for a hyperspace star
struct HyperStar {
    let startPoint: CGPoint
    let angle: CGFloat
    let width: CGFloat
    let speed: CGFloat
    let color: Color
}

// Individual animated star streak view
struct StarStreakView: View {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let width: CGFloat
    let color: Color
    let progress: Double
    
    var body: some View {
        Path { path in
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        .stroke(color, lineWidth: width)
        .blur(radius: width * 0.5)
        .opacity(min(1, max(0.2, progress * 2)))
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