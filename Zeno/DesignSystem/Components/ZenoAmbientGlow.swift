import SwiftUI

// MARK: - Ambient Glow Component

/// A reusable animated ambient glow effect for onboarding and illustration backgrounds.
/// Provides two variants: centered glow and stage lighting (from top).
///
/// Uses design tokens where applicable:
/// - Colors: `ZenoSemanticTokens.Gradients` (Acid + Sand)
/// - Opacity: `ZenoTokens.OpacityLevel`
/// - Motion: `ZenoSemanticTokens.Motion.Duration.breathe`
struct ZenoAmbientGlow: View {
    
    /// The style of ambient glow.
    enum Style {
        /// Centered radial glow behind content.
        /// Best for: Floating illustrations, coin displays.
        case centered
        
        /// "Stage lighting" from top of screen - only bottom portion visible.
        /// Best for: Onboarding screens, hero sections.
        case stageLight
    }
    
    let style: Style
    
    /// Whether the glow should animate (pulse). Default: true.
    var animated: Bool = true
    
    // MARK: - Animation Config (Using Design Tokens)
    
    private enum Config {
        // Opacity range for pulse animation
        static let opacityMin: Double = ZenoTokens.OpacityLevel._10  // 0.10
        static let opacityMax: Double = ZenoTokens.OpacityLevel._25  // 0.25
        
        // Pulse speed derived from Motion.Duration.breathe (2.0s cycle)
        // We use 1/breathe to get the frequency (0.5 Hz = one cycle per 2 seconds)
        static let pulseSpeed: Double = 1.0 / ZenoSemanticTokens.Motion.Duration.breathe
        
        // Centered style (relative to container)
        static let centeredSizeRatio: CGFloat = 0.85
        static let centeredOffsetYRatio: CGFloat = -0.06
        // Note: Blur values exceed token scale (_3xl = 32pt max).
        // These large blurs are specific to ambient glow effects.
        static let centeredBlur: CGFloat = ZenoTokens.BlurRadiusScale._3xl * 1.75  // ~56pt
        
        // Stage light style: Circle center at top edge, only bottom half visible
        static let stageLightSizeRatio: CGFloat = 0.80  // Slightly larger for more coverage
        // Center positioned at y=0 (top of screen) - shows bottom half of circle
        static let stageLightOffsetYRatio: CGFloat = 0.0
        static let stageLightBlur: CGFloat = ZenoTokens.BlurRadiusScale._3xl * 2.0  // ~64pt (tighter for visibility)
        
        // Stage light has slightly higher opacity for better visibility
        static let stageLightOpacityMin: Double = ZenoTokens.OpacityLevel._10 + 0.05  // 0.15
        static let stageLightOpacityMax: Double = ZenoTokens.OpacityLevel._25 + 0.10  // 0.35
    }
    
    // Opacity bounds based on style
    private var opacityMin: Double {
        switch style {
        case .centered: return Config.opacityMin
        case .stageLight: return Config.stageLightOpacityMin
        }
    }
    
    private var opacityMax: Double {
        switch style {
        case .centered: return Config.opacityMax
        case .stageLight: return Config.stageLightOpacityMax
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if animated {
                animatedGlow(in: geometry)
            } else {
                staticGlow(
                    opacity: (opacityMin + opacityMax) / 2,
                    in: geometry
                )
            }
        }
    }
    
    // MARK: - Animated Version
    
    @ViewBuilder
    private func animatedGlow(in geometry: GeometryProxy) -> some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let phase = sin(time * Config.pulseSpeed * .pi * 2)
            let opacity = opacityMin + (opacityMax - opacityMin) * ((phase + 1) / 2)
            
            staticGlow(opacity: opacity, in: geometry)
        }
    }
    
    // MARK: - Static Glow
    
    @ViewBuilder
    private func staticGlow(opacity: Double, in geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let screenWidth = geometry.size.width
        
        switch style {
        case .centered:
            let size = screenWidth * Config.centeredSizeRatio
            let offsetY = screenHeight * Config.centeredOffsetYRatio
            
            Circle()
                .fill(ZenoSemanticTokens.Gradients.ambientGlow(opacity: opacity))
                .frame(width: size, height: size)
                .blur(radius: Config.centeredBlur)
                .position(x: screenWidth / 2, y: screenHeight / 2 + offsetY)
            
        case .stageLight:
            let size = screenHeight * Config.stageLightSizeRatio
            let offsetY = screenHeight * Config.stageLightOffsetYRatio
            
            Circle()
                .fill(ZenoSemanticTokens.Gradients.stageLight(opacity: opacity))
                .frame(width: size, height: size)
                .blur(radius: Config.stageLightBlur)
                .position(x: screenWidth / 2, y: offsetY)
        }
    }
}

// MARK: - Convenience Initializers

extension ZenoAmbientGlow {
    /// Creates a centered ambient glow (original style).
    static var centered: ZenoAmbientGlow {
        ZenoAmbientGlow(style: .centered)
    }
    
    /// Creates a stage lighting glow from top of screen.
    static var stageLight: ZenoAmbientGlow {
        ZenoAmbientGlow(style: .stageLight)
    }
}

// MARK: - Preview

#Preview("Centered Glow") {
    ZStack {
        ZenoSemanticTokens.Theme.background
            .ignoresSafeArea()
        
        ZenoAmbientGlow.centered
            .ignoresSafeArea()
        
        Text("Centered Glow")
            .font(ZenoTokens.Typography.titleLarge)
            .foregroundColor(ZenoSemanticTokens.Theme.foreground)
    }
}

#Preview("Stage Light Glow") {
    ZStack {
        ZenoSemanticTokens.Theme.background
            .ignoresSafeArea()
        
        ZenoAmbientGlow.stageLight
            .ignoresSafeArea()
        
        VStack {
            Text("Stage Lighting")
                .font(ZenoTokens.Typography.titleLarge)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                .padding(.top, 100)
            
            Spacer()
        }
    }
}
