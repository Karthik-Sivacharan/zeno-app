import SwiftUI

// MARK: - Shimmer Effect

/// A shimmering gradient effect that sweeps across content.
/// Use for active states, loading indicators, or to draw attention.
/// Works by animating a gradient mask over the content.
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    let duration: Double
    
    @State private var startPoint: UnitPoint = .init(x: -1.5, y: 0.5)
    @State private var endPoint: UnitPoint = .init(x: -0.5, y: 0.5)
    
    // Shimmer gradient colors using design tokens
    // Brass highlight creates a gold shimmer — fits the premium/ancient Zeno vibe
    private let shimmerColors: [Color] = [
        ZenoSemanticTokens.Theme.primary,
        ZenoSemanticTokens.Theme.primary,
        ZenoTokens.ColorBase.Brass._300,
        ZenoSemanticTokens.Theme.primary,
        ZenoSemanticTokens.Theme.primary
    ]
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay {
                    LinearGradient(
                        colors: shimmerColors,
                        startPoint: startPoint,
                        endPoint: endPoint
                    )
                    .mask(content)
                }
                .onAppear {
                    startShimmer()
                }
        } else {
            content
        }
    }
    
    private func startShimmer() {
        withAnimation(
            .linear(duration: duration)
            .repeatForever(autoreverses: false)
        ) {
            startPoint = .init(x: 1, y: 0.5)
            endPoint = .init(x: 2.5, y: 0.5)
        }
    }
}

// MARK: - Pulse Effect

/// A subtle scale pulse effect for "alive" indicators.
/// Use for status dots, active states, or breathing effects.
struct PulseModifier: ViewModifier {
    let isActive: Bool
    let minScale: CGFloat
    let maxScale: CGFloat
    
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive && isPulsing ? maxScale : minScale)
            .animation(
                isActive ? .easeInOut(duration: ZenoSemanticTokens.Motion.Duration.breathe)
                    .repeatForever(autoreverses: true) : .default,
                value: isPulsing
            )
            .onAppear {
                if isActive { isPulsing = true }
            }
            .onChange(of: isActive) { _, newValue in
                isPulsing = newValue
            }
    }
}

// MARK: - Fade In Effect

/// A simple opacity fade-in animation.
/// Use for content appearing on screen.
struct FadeInModifier: ViewModifier {
    let isVisible: Bool
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: duration), value: isVisible)
    }
}

// MARK: - Scale In Effect

/// A combined scale + opacity entrance animation.
/// Use for modals, cards, or emphasis moments.
struct ScaleInModifier: ViewModifier {
    let isVisible: Bool
    let initialScale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : initialScale)
            .animation(ZenoSemanticTokens.Motion.Ease.mechanical, value: isVisible)
    }
}

// MARK: - Glow Effect

/// A subtle glow/shadow effect using the primary color.
/// Use for active/highlighted elements.
struct GlowModifier: ViewModifier {
    let isActive: Bool
    let intensity: GlowIntensity
    
    enum GlowIntensity {
        case low
        case high
        
        var spec: ZenoSemanticTokens.GlowSpec {
            switch self {
            case .low: return ZenoSemanticTokens.Glow.low
            case .high: return ZenoSemanticTokens.Glow.high
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: isActive ? intensity.spec.color : .clear,
                radius: isActive ? intensity.spec.radius : 0
            )
            .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.fast), value: isActive)
    }
}

// MARK: - View Extensions

extension View {
    /// Adds a shimmering gradient sweep effect.
    /// - Parameters:
    ///   - isActive: Whether the shimmer is animating
    ///   - duration: How long one shimmer cycle takes (default: 2s)
    func shimmer(isActive: Bool = true, duration: Double = ZenoSemanticTokens.Motion.Duration.breathe) -> some View {
        modifier(ShimmerModifier(isActive: isActive, duration: duration))
    }
    
    /// Adds a subtle breathing pulse effect.
    /// - Parameters:
    ///   - isActive: Whether the pulse is animating
    ///   - minScale: Minimum scale (default: 0.95)
    ///   - maxScale: Maximum scale (default: 1.05)
    func pulse(isActive: Bool = true, minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05) -> some View {
        modifier(PulseModifier(isActive: isActive, minScale: minScale, maxScale: maxScale))
    }
    
    /// Adds a fade-in entrance animation.
    /// - Parameters:
    ///   - isVisible: Whether the content is visible
    ///   - duration: Animation duration (default: fast)
    func fadeIn(isVisible: Bool = true, duration: Double = ZenoSemanticTokens.Motion.Duration.fast) -> some View {
        modifier(FadeInModifier(isVisible: isVisible, duration: duration))
    }
    
    /// Adds a scale + fade entrance animation.
    /// - Parameters:
    ///   - isVisible: Whether the content is visible
    ///   - initialScale: Starting scale before animating to 1.0 (default: 0.95)
    func scaleIn(isVisible: Bool = true, initialScale: CGFloat = 0.95) -> some View {
        modifier(ScaleInModifier(isVisible: isVisible, initialScale: initialScale))
    }
    
    /// Adds a glow/shadow effect using the primary color.
    /// - Parameters:
    ///   - isActive: Whether the glow is visible
    ///   - intensity: Glow intensity level (.low or .high)
    func glow(isActive: Bool = true, intensity: GlowModifier.GlowIntensity = .low) -> some View {
        modifier(GlowModifier(isActive: isActive, intensity: intensity))
    }
}

// MARK: - Preview

#Preview("Animation Modifiers") {
    VStack(spacing: 40) {
        // Shimmer example
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
            Text("Shimmer")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                Image(systemName: "shield.fill")
                Text("Zeno is shielding your apps")
            }
            .font(ZenoTokens.Typography.labelMedium)
            .foregroundColor(ZenoSemanticTokens.Theme.primary)
            .shimmer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        // Pulse example
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
            Text("Pulse")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            HStack(spacing: ZenoSemanticTokens.Space.sm) {
                Circle()
                    .fill(ZenoSemanticTokens.Theme.primary)
                    .frame(width: 12, height: 12)
                    .pulse()
                
                Text("Active status")
                    .font(ZenoTokens.Typography.labelMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        // Glow example
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
            Text("Glow")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                .fill(ZenoSemanticTokens.Theme.primary)
                .frame(width: 120, height: 44)
                .glow(intensity: .high)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(ZenoSemanticTokens.Space.lg)
    .background(ZenoSemanticTokens.Theme.background)
}
