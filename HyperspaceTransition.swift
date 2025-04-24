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
                HyperspaceJumpView()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Start hyperspace sequence
            withAnimation(.easeIn(duration: 0.2)) {
                showHyperspace = true
            }
            
            // After 0.7 seconds, show the destination
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showHyperspace = false
                    showDestination = true
                }
            }
        }
    }
}

// Real-time animated hyperspace view
struct HyperspaceJumpView: View {
    // Animation duration
    private let animationDuration: Double = 0.6
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.01, paused: false)) { context in
            // Calculate progress (0 to 1) based on time since view appeared
            let progress = min(1.0, context.date.timeIntervalSince1970.truncatingRemainder(dividingBy: 100) / animationDuration)
            
            HyperspaceStarfieldView(progress: progress)
                .id(context.date.timeIntervalSinceReferenceDate) // Force redraw each frame
        }
    }
}

// Full-screen cinematic hyperspace view with real-time animation
struct HyperspaceStarfieldView: View {
    // The current animation progress (0 to 1)
    let progress: Double
    
    // Star configurations - created only once per view instance
    let stars: [HyperStar] = generateStars(count: 200)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep space background
                Color.black
                
                // Central glow that fades as animation progresses
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
                    .opacity(max(0, 1 - progress * 1.5))
                    .blur(radius: 5)
                
                // Dynamic star streaks
                ForEach(stars.indices, id: \.self) { index in
                    let star = stars[index]
                    
                    // Calculate end point based on current progress
                    let endPoint = calculateEndPoint(
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        angle: star.angle,
                        progress: progress,
                        speed: star.speed,
                        size: geometry.size
                    )
                    
                    // Draw streak based on star's starting position relative to center
                    let startPoint = calculateStartPoint(
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        angle: star.angle,
                        progress: progress,
                        initialRadius: star.initialRadius
                    )
                    
                    Path { path in
                        path.move(to: startPoint)
                        path.addLine(to: endPoint)
                    }
                    .stroke(
                        star.color,
                        style: StrokeStyle(
                            lineWidth: star.width,
                            lineCap: .round
                        )
                    )
                    .blur(radius: star.width * 0.5)
                    // Calculate opacity based on distance and progress
                    .opacity(calculateOpacity(startPoint: startPoint, endPoint: endPoint, progress: progress))
                }
            }
        }
    }
    
    // Generate a fixed set of stars with random properties
    private static func generateStars(count: Int) -> [HyperStar] {
        (0..<count).map { _ in
            let angle = CGFloat.random(in: 0..<2*CGFloat.pi)
            return HyperStar(
                angle: angle,
                initialRadius: CGFloat.random(in: 0...15),
                width: CGFloat.random(in: 1...3),
                speed: CGFloat.random(in: 0.7...1.5),
                color: starColor()
            )
        }
    }
    
    // Calculate starting point that moves slightly outward as animation progresses
    private func calculateStartPoint(center: CGPoint, angle: CGFloat, progress: Double, initialRadius: CGFloat) -> CGPoint {
        // Start radius grows slightly with progress
        let startRadius = initialRadius * (1 + progress * 0.5)
        
        return CGPoint(
            x: center.x + cos(Double(angle)) * startRadius,
            y: center.y + sin(Double(angle)) * startRadius
        )
    }
    
    // Calculate end point that extends outward as animation progresses
    private func calculateEndPoint(center: CGPoint, angle: CGFloat, progress: Double, speed: CGFloat, size: CGSize) -> CGPoint {
        // Maximum possible distance to ensure streaks extend beyond screen
        let maxDistance = max(size.width, size.height) * 1.5
        
        // Current distance based on progress - use easeOut curve for more dynamic feel
        let easedProgress = 1 - pow(1 - progress, 2) // Quadratic ease out
        let distance = maxDistance * easedProgress * speed
        
        return CGPoint(
            x: center.x + cos(Double(angle)) * distance,
            y: center.y + sin(Double(angle)) * distance
        )
    }
    
    // Calculate opacity that fades as stars reach the edge
    private func calculateOpacity(startPoint: CGPoint, endPoint: CGPoint, progress: Double) -> Double {
        // Distance from end point to start point
        let distance = sqrt(
            pow(endPoint.x - startPoint.x, 2) +
            pow(endPoint.y - startPoint.y, 2)
        )
        
        // Normalize by max expected distance
        let normalizedDistance = distance / 2000
        
        // Fade out as distance increases, but ensure visibility during early animation
        let distanceOpacity = max(0, 1.0 - normalizedDistance * 0.8)
        
        // Ensure streaks stay visible during early animation
        return min(1, max(0.2, distanceOpacity + (1 - progress) * 0.5))
    }
    
    // Generate random star colors with blue/white bias
    private static func starColor() -> Color {
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
    let angle: CGFloat        // Direction angle in radians
    let initialRadius: CGFloat // Initial distance from center
    let width: CGFloat        // Width of the streak
    let speed: CGFloat        // Relative speed factor
    let color: Color          // Color of the streak
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