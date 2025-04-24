import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    var x: CGFloat      // Position X (percentage of screen width)
    var y: CGFloat      // Position Y (percentage of screen height)
    var size: CGFloat   // Size of the star
    var brightness: Double // Current brightness (for twinkling)
    var twinkleSpeed: Double // How fast the star twinkles
    var parallaxFactor: CGFloat // How much the star moves with parallax (depth simulation)
    var color: Color    // Star color
}

struct StarfieldView: View {
    // Configuration properties
    private let starCount: Int
    private let twinkleAnimation: Bool
    private let parallaxEnabled: Bool
    
    // State for the stars
    @State private var stars: [Star] = []
    
    // State for parallax effect
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    
    // Initialize with defaults that can be overridden
    init(
        starCount: Int = 100,
        twinkleAnimation: Bool = true,
        parallaxEnabled: Bool = true
    ) {
        self.starCount = starCount
        self.twinkleAnimation = twinkleAnimation
        self.parallaxEnabled = parallaxEnabled
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep space background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Stars layer
                ForEach(stars) { star in
                    Circle()
                        .fill(star.color)
                        .frame(width: star.size, height: star.size)
                        .position(
                            x: star.x * geometry.size.width + (parallaxEnabled ? xOffset * star.parallaxFactor : 0),
                            y: star.y * geometry.size.height + (parallaxEnabled ? yOffset * star.parallaxFactor : 0)
                        )
                        .opacity(star.brightness)
                }
                
                // Optional distant nebula effect
                Color.purple.opacity(0.05)
                    .blendMode(.plusLighter)
                    .offset(
                        x: parallaxEnabled ? xOffset * 0.1 : 0,
                        y: parallaxEnabled ? yOffset * 0.1 : 0
                    )
            }
            .ignoresSafeArea()
            .onAppear {
                // Generate the stars when the view appears
                generateStars(count: starCount, in: geometry.size)
                
                // Start the twinkling animation
                if twinkleAnimation {
                    animateStarTwinkling()
                }
                
                // Start subtle parallax motion
                if parallaxEnabled {
                    animateParallax()
                }
            }
            // Add gesture if needed for interactive parallax
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if parallaxEnabled {
                            // Subtle movement based on drag
                            xOffset = value.translation.width / 20
                            yOffset = value.translation.height / 20
                        }
                    }
                    .onEnded { _ in
                        if parallaxEnabled {
                            // Gently reset position when drag ends
                            withAnimation(.easeOut(duration: 1.5)) {
                                xOffset = 0
                                yOffset = 0
                            }
                        }
                    }
            )
        }
    }
    
    // Generate a set of random stars
    private func generateStars(count: Int, in size: CGSize) {
        stars = (0..<count).map { _ in
            let starSize = CGFloat.random(in: 1...3)
            let depth = CGFloat.random(in: 0.2...1.0)
            
            // Create a subtle color variation for some stars
            let color: Color
            let colorRoll = Int.random(in: 0...100)
            if colorRoll < 80 {
                // 80% white/blue-white stars
                color = Color(
                    red: Double.random(in: 0.8...1.0),
                    green: Double.random(in: 0.8...1.0),
                    blue: 1.0
                )
            } else if colorRoll < 90 {
                // 10% reddish stars
                color = Color(
                    red: Double.random(in: 0.9...1.0),
                    green: Double.random(in: 0.6...0.8),
                    blue: Double.random(in: 0.6...0.8)
                )
            } else {
                // 10% yellow/amber stars
                color = Color(
                    red: Double.random(in: 0.9...1.0),
                    green: Double.random(in: 0.8...1.0),
                    blue: Double.random(in: 0.4...0.6)
                )
            }
            
            return Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: starSize,
                brightness: Double.random(in: 0.5...1.0),
                twinkleSpeed: Double.random(in: 0.3...2.0),
                parallaxFactor: depth * 5, // More distant stars move less (smaller parallax)
                color: color
            )
        }
    }
    
    // Animate star twinkling
    private func animateStarTwinkling() {
        // Create a continuous animation loop
        let baseAnimation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        
        for i in 0..<stars.count {
            // Stagger the animations by applying different delays
            let delay = Double.random(in: 0...3)
            let duration = stars[i].twinkleSpeed
            
            // Custom animation for each star
            let animation = baseAnimation
                .delay(delay)
                .speed(duration)
            
            // Animate brightness changes
            withAnimation(animation) {
                stars[i].brightness = Double.random(in: 0.5...1.0)
            }
        }
    }
    
    // Add subtle autonomous parallax motion
    private func animateParallax() {
        // Create slow, gentle movement
        withAnimation(
            Animation.easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
        ) {
            xOffset = CGFloat.random(in: -10...10)
            yOffset = CGFloat.random(in: -10...10)
        }
    }
}

// Preview
#Preview {
    ZStack {
        StarfieldView(starCount: 150)
        
        // Sample overlay content to see how it looks
        VStack {
            Text("Star Wars")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Spacer().frame(height: 50)
            
            Text("In a galaxy far, far away...")
                .foregroundColor(.white)
        }
        .padding()
    }
} 