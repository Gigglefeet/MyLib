import SwiftUI

struct LightsaberView: View {
    // Whether the lightsaber is lit (equivalent to a filled star)
    var isLit: Bool
    
    // The color of the lightsaber blade when lit
    var color: Color
    
    // Size option to match font sizes
    var size: Font
    
    // Animation state properties
    @State private var isAnimating: Bool = false
    @State private var glowIntensity: Double = 1.0
    
    // Size constants based on font size
    private var bladeLength: CGFloat {
        switch size {
        case .caption, .caption2:
            return 14
        case .footnote:
            return 16
        case .body:
            return 20
        default:
            return 18 // Default size
        }
    }
    
    private var bladeWidth: CGFloat {
        switch size {
        case .caption, .caption2:
            return 2.5
        case .footnote:
            return 3
        case .body:
            return 4
        default:
            return 3.5
        }
    }
    
    private var hiltLength: CGFloat {
        return bladeWidth * 2.5
    }
    
    private var hiltWidth: CGFloat {
        return bladeWidth * 1.2
    }
    
    var body: some View {
        HStack(spacing: 1) {
            // Blade with animation
            Capsule()
                .fill(isLit ? color : Color.gray.opacity(0.3))
                .frame(width: isLit ? bladeLength : 1, height: bladeWidth) // Contract when off
                .opacity(isLit ? 1.0 : 0.5)
                // Add glow effect when lit with animation
                .shadow(color: isLit ? color.opacity(0.7 * glowIntensity) : .clear, 
                       radius: isLit ? 2 * CGFloat(glowIntensity) : 0)
                // Add ignition animation
                .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isLit)
            
            // Hilt
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.gray.opacity(0.8))
                .frame(width: hiltLength, height: hiltWidth)
                // Add metallic gradient to hilt
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.gray.opacity(0.4), .white.opacity(0.7), .gray.opacity(0.4)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .rotationEffect(.degrees(45)) // Angle the lightsaber diagonally
        .onAppear {
            // Only start the humming animation if the lightsaber is lit
            if isLit {
                startHummingAnimation()
            }
        }
        .onChange(of: isLit) { _, newValue in
            if newValue {
                // Start the humming animation when lightsaber is turned on
                startHummingAnimation()
            } else {
                // Stop the animation when turned off
                isAnimating = false
            }
        }
    }
    
    // Function to create the subtle humming effect
    private func startHummingAnimation() {
        isAnimating = true
        
        // Create a subtle pulsing glow effect
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 0.85 // Pulse down to 85%
        }
        
        // After a brief delay, bring the intensity back up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            if isAnimating {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowIntensity = 1.0 // Back to 100%
                }
            }
        }
    }
}

// Helper extension for predefined lightsaber colors
extension LightsaberView {
    static let lightsaberColors: [Color] = [
        .yellow,
        .red,
        .green,
        .blue,
        .purple
    ]
    
    // Static factory method to get color based on index (1-5)
    static func colorForIndex(_ index: Int) -> Color {
        guard index >= 1 && index <= 5 else {
            return .yellow // Default to yellow for out of range
        }
        return lightsaberColors[index - 1]
    }
}

// Preview
#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 20) {
        // Row of all 5 colors, lit
        HStack(spacing: 10) {
            ForEach(0..<5) { index in
                LightsaberView(
                    isLit: true,
                    color: LightsaberView.lightsaberColors[index],
                    size: .caption
                )
            }
        }
        
        // Example of 3/5 rating with sequential colors
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { index in
                LightsaberView(
                    isLit: index <= 3,
                    color: LightsaberView.colorForIndex(index),
                    size: .body
                )
            }
        }
        
        // Unlit row with bigger size
        HStack(spacing: 10) {
            ForEach(0..<5) { index in
                LightsaberView(
                    isLit: false,
                    color: LightsaberView.lightsaberColors[index],
                    size: .headline
                )
            }
        }
        
        // Animated toggle example
        AnimatedLightsaberDemo()
    }
    .padding()
    .background(Color.black)
}

// Demo view for animation preview
struct AnimatedLightsaberDemo: View {
    @State private var isOn = false
    
    var body: some View {
        VStack {
            Button("Toggle Lightsaber") {
                withAnimation {
                    isOn.toggle()
                }
            }
            .foregroundColor(.white)
            .padding(.bottom, 10)
            
            LightsaberView(
                isLit: isOn,
                color: .green,
                size: .title
            )
            .padding()
        }
    }
} 