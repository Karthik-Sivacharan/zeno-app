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
        ZenoTokens.ColorBase.Olive._500,
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

// MARK: - Staggered Appear Effect (Apple-style)

/// Configuration for staggered entrance animations.
/// Adjust these values to fine-tune the feel of your animations.
enum StaggerConfig {
    /// Base delay before the first element appears
    static let initialDelay: Double = 0.1
    /// Delay increment between each staggered element
    static let staggerInterval: Double = 0.08
    /// Duration of each element's entrance animation
    static let elementDuration: Double = 0.5
    /// Vertical offset for slide-up entrance (in points)
    static let slideOffset: CGFloat = 24
    /// Spring response for bouncy feel (lower = snappier)
    static let springResponse: Double = 0.6
    /// Spring damping (lower = more bounce, 1 = no bounce)
    static let springDamping: Double = 0.85
}

/// A modifier that animates content appearing with a slide-up + fade effect.
/// Perfect for staggered entrance animations (title, then description, then CTA).
struct SlideUpFadeModifier: ViewModifier {
    let isVisible: Bool
    let delay: Double
    let duration: Double
    let offset: CGFloat
    let useSpring: Bool
    
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : offset)
            .onAppear {
                guard isVisible && !hasAppeared else { return }
                let animation: Animation = useSpring
                    ? .spring(response: StaggerConfig.springResponse, dampingFraction: StaggerConfig.springDamping)
                    : .easeOut(duration: duration)
                
                withAnimation(animation.delay(delay)) {
                    hasAppeared = true
                }
            }
            .onChange(of: isVisible) { _, newValue in
                if newValue && !hasAppeared {
                    let animation: Animation = useSpring
                        ? .spring(response: StaggerConfig.springResponse, dampingFraction: StaggerConfig.springDamping)
                        : .easeOut(duration: duration)
                    
                    withAnimation(animation.delay(delay)) {
                        hasAppeared = true
                    }
                } else if !newValue {
                    hasAppeared = false
                }
            }
    }
}

/// A modifier for staggered content blocks (e.g., 0th, 1st, 2nd item in a list).
/// Automatically calculates delay based on index.
struct StaggeredItemModifier: ViewModifier {
    let index: Int
    let isVisible: Bool
    let useSpring: Bool
    
    private var delay: Double {
        StaggerConfig.initialDelay + (Double(index) * StaggerConfig.staggerInterval)
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(SlideUpFadeModifier(
                isVisible: isVisible,
                delay: delay,
                duration: StaggerConfig.elementDuration,
                offset: StaggerConfig.slideOffset,
                useSpring: useSpring
            ))
    }
}

// MARK: - Typewriter Text Effect

/// Animates text appearing character by character, like a typewriter.
/// Use sparingly for dramatic headlines or impact moments.
struct TypewriterModifier: ViewModifier {
    let text: String
    let isActive: Bool
    let characterDelay: Double
    let onComplete: (() -> Void)?
    
    @State private var visibleCount: Int = 0
    @State private var timer: Timer?
    
    func body(content: Content) -> some View {
        // We overlay a Text view that shows partial text
        Text(String(text.prefix(visibleCount)))
            .onAppear {
                guard isActive else { return }
                startTypewriter()
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startTypewriter()
                } else {
                    stopTypewriter()
                }
            }
            .onDisappear {
                stopTypewriter()
            }
    }
    
    private func startTypewriter() {
        visibleCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: characterDelay, repeats: true) { t in
            if visibleCount < text.count {
                visibleCount += 1
            } else {
                t.invalidate()
                onComplete?()
            }
        }
    }
    
    private func stopTypewriter() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Onboarding Page Transitions

/// Custom transitions optimized for onboarding flows.
/// Combines movement, scale, and opacity for a polished feel.
enum OnboardingTransition {
    /// Slide from trailing edge with fade (for forward navigation)
    static var slideForward: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: SlideTransitionModifier(offset: 60, opacity: 0, scale: 0.95),
                identity: SlideTransitionModifier(offset: 0, opacity: 1, scale: 1)
            ),
            removal: .modifier(
                active: SlideTransitionModifier(offset: -40, opacity: 0, scale: 0.98),
                identity: SlideTransitionModifier(offset: 0, opacity: 1, scale: 1)
            )
        )
    }
    
    /// Slide from leading edge with fade (for backward navigation)
    static var slideBackward: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: SlideTransitionModifier(offset: -60, opacity: 0, scale: 0.95),
                identity: SlideTransitionModifier(offset: 0, opacity: 1, scale: 1)
            ),
            removal: .modifier(
                active: SlideTransitionModifier(offset: 40, opacity: 0, scale: 0.98),
                identity: SlideTransitionModifier(offset: 0, opacity: 1, scale: 1)
            )
        )
    }
    
    /// A subtle crossfade with slight scale - good for dramatic content changes
    static var crossfadeScale: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.96)),
            removal: .opacity.combined(with: .scale(scale: 1.02))
        )
    }
    
    /// Rise from bottom with fade - good for modals/CTAs
    static var riseUp: AnyTransition {
        .modifier(
            active: SlideTransitionModifier(offset: 30, opacity: 0, scale: 1, axis: .vertical),
            identity: SlideTransitionModifier(offset: 0, opacity: 1, scale: 1, axis: .vertical)
        )
    }
}

/// Helper modifier for custom slide transitions with combined effects.
struct SlideTransitionModifier: ViewModifier {
    let offset: CGFloat
    let opacity: Double
    let scale: CGFloat
    var axis: Axis = .horizontal
    
    enum Axis {
        case horizontal, vertical
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: axis == .horizontal ? offset : 0, y: axis == .vertical ? offset : 0)
            .opacity(opacity)
            .scaleEffect(scale)
    }
}

// MARK: - Tab Transitions

/// Custom transitions optimized for tab bar navigation.
/// Subtle, fast, and content-focused — fits the Zeno minimal aesthetic.
enum TabTransition {
    /// Gentle fade with subtle vertical lift — the default Zeno tab transition.
    /// Content rises slightly as it fades in, creating a sense of depth without being distracting.
    static var lift: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: TabTransitionModifier(offsetY: 8, opacity: 0, scale: 1),
                identity: TabTransitionModifier(offsetY: 0, opacity: 1, scale: 1)
            ),
            removal: .modifier(
                active: TabTransitionModifier(offsetY: -4, opacity: 0, scale: 1),
                identity: TabTransitionModifier(offsetY: 0, opacity: 1, scale: 1)
            )
        )
    }
    
    /// Crossfade with a hint of scale — more dramatic, good for settings/profile.
    static var breathe: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.98)),
            removal: .opacity.combined(with: .scale(scale: 1.01))
        )
    }
    
    /// Pure opacity fade — most minimal, zero motion.
    static var fade: AnyTransition {
        .opacity
    }
}

/// Helper modifier for tab transitions with vertical offset and opacity.
struct TabTransitionModifier: ViewModifier {
    let offsetY: CGFloat
    let opacity: Double
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .opacity(opacity)
            .scaleEffect(scale)
    }
}

// MARK: - Blur Transition Effect

/// A modifier that combines blur with opacity for dreamy transitions.
/// Use for atmospheric content changes.
struct BlurFadeModifier: ViewModifier {
    let isVisible: Bool
    let maxBlur: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .blur(radius: isVisible ? 0 : maxBlur)
            .animation(.easeInOut(duration: duration), value: isVisible)
    }
}

// MARK: - Content Reveal Effect

/// Reveals content from a specific edge with a mask animation.
/// Creates a "curtain reveal" or "wipe" effect.
struct RevealModifier: ViewModifier {
    let isRevealed: Bool
    let edge: Edge
    let duration: Double
    
    @State private var progress: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .mask(
                GeometryReader { geo in
                    Rectangle()
                        .frame(
                            width: edge.isHorizontal ? geo.size.width * progress : geo.size.width,
                            height: edge.isHorizontal ? geo.size.height : geo.size.height * progress
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: edge.alignment)
                }
            )
            .onAppear {
                if isRevealed {
                    withAnimation(.easeOut(duration: duration)) {
                        progress = 1
                    }
                }
            }
            .onChange(of: isRevealed) { _, newValue in
                withAnimation(.easeOut(duration: duration)) {
                    progress = newValue ? 1 : 0
                }
            }
    }
}

private extension Edge {
    var isHorizontal: Bool {
        self == .leading || self == .trailing
    }
    
    var alignment: Alignment {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
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
    
    // MARK: - Onboarding Animation Extensions
    
    /// Adds a slide-up + fade entrance animation with configurable delay.
    /// Perfect for staggered content reveals.
    /// - Parameters:
    ///   - isVisible: Whether the content should be visible
    ///   - delay: Delay before animation starts (default: 0)
    ///   - duration: Animation duration (default: from StaggerConfig)
    ///   - offset: Vertical slide distance (default: from StaggerConfig)
    ///   - useSpring: Whether to use spring animation (default: true)
    func slideUpFade(
        isVisible: Bool = true,
        delay: Double = 0,
        duration: Double = StaggerConfig.elementDuration,
        offset: CGFloat = StaggerConfig.slideOffset,
        useSpring: Bool = true
    ) -> some View {
        modifier(SlideUpFadeModifier(
            isVisible: isVisible,
            delay: delay,
            duration: duration,
            offset: offset,
            useSpring: useSpring
        ))
    }
    
    /// Applies a staggered entrance animation based on item index.
    /// Use in lists or sequential content blocks.
    /// - Parameters:
    ///   - index: The item's position in the sequence (0, 1, 2...)
    ///   - isVisible: Whether the content should be visible
    ///   - useSpring: Whether to use spring animation (default: true)
    func staggeredItem(index: Int, isVisible: Bool = true, useSpring: Bool = true) -> some View {
        modifier(StaggeredItemModifier(index: index, isVisible: isVisible, useSpring: useSpring))
    }
    
    /// Adds a blur + fade transition effect.
    /// Creates a dreamy, atmospheric feel.
    /// - Parameters:
    ///   - isVisible: Whether the content is visible
    ///   - maxBlur: Maximum blur radius when hidden (default: 8)
    ///   - duration: Animation duration (default: medium)
    func blurFade(
        isVisible: Bool = true,
        maxBlur: CGFloat = 8,
        duration: Double = ZenoSemanticTokens.Motion.Duration.medium
    ) -> some View {
        modifier(BlurFadeModifier(isVisible: isVisible, maxBlur: maxBlur, duration: duration))
    }
    
    /// Reveals content with a mask animation from a specific edge.
    /// Creates a "curtain reveal" or "wipe" effect.
    /// - Parameters:
    ///   - isRevealed: Whether the content is revealed
    ///   - edge: The edge to reveal from (default: .leading)
    ///   - duration: Animation duration (default: medium)
    func reveal(
        isRevealed: Bool = true,
        from edge: Edge = .leading,
        duration: Double = ZenoSemanticTokens.Motion.Duration.medium
    ) -> some View {
        modifier(RevealModifier(isRevealed: isRevealed, edge: edge, duration: duration))
    }
}

// MARK: - Previews

#Preview("Basic Effects") {
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

#Preview("Staggered Onboarding") {
    StaggeredOnboardingPreview()
}

/// Interactive preview demonstrating staggered animations
private struct StaggeredOnboardingPreview: View {
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            ZenoSemanticTokens.Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                    // Title - appears first
                    Text("Walk to Unlock")
                        .font(ZenoTokens.Typography.displayXSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .staggeredItem(index: 0, isVisible: isVisible)
                    
                    // Description - appears second
                    Text("Lock your distracting apps. To access them, you must walk to earn credits.")
                        .font(ZenoTokens.Typography.bodyLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .staggeredItem(index: 1, isVisible: isVisible)
                    
                    // Extra content - appears third
                    HStack(spacing: ZenoSemanticTokens.Space.sm) {
                        Image(systemName: "figure.walk")
                        Text("1,000 steps = 10 minutes")
                    }
                    .font(ZenoTokens.Typography.labelMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.accentForeground)
                    .staggeredItem(index: 2, isVisible: isVisible)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // CTA - appears last
                Button(action: { isVisible = false }) {
                    Text("Next")
                        .font(ZenoTokens.Typography.labelLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.primaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ZenoSemanticTokens.Space.lg)
                        .background(ZenoSemanticTokens.Theme.primary)
                }
                .staggeredItem(index: 3, isVisible: isVisible)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
            }
        }
        .onAppear {
            // Trigger animation on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isVisible = true
            }
        }
        .onTapGesture {
            // Reset and replay on tap
            isVisible = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isVisible = true
            }
        }
    }
}
