import SwiftUI
import SVGView

struct OnboardingFlowView: View {
    @State private var step = 0
    @State private var previousStep = 0
    @Binding var hasCompletedOnboarding: Bool
    @State private var estimatedHours = 0
    
    var body: some View {
        ZStack {
            // STABLE BACKGROUND - Never animates, prevents stuttering
            OnboardingBackground()
            
            // CONTENT ONLY - This is what transitions
            contentForStep
                .animation(.smooth(duration: 0.4), value: step)
        }
    }
    
    @ViewBuilder
    private var contentForStep: some View {
        switch step {
        case 0:
            OnboardingContentView(
                title: "The Dopamine Trap",
                description: "We spend hours on our phones because they give us easy, unearned dopamine. It's not your fault, but it is a trap.",
                illustrationName: "zen-svg-1",
                onNext: advanceStep
            )
            .transition(contentTransition)
            
        case 1:
            OnboardingContentView(
                title: "Walk to Unlock",
                description: "Lock your distracting apps. To access them, you must walk to earn credits. Make your scrolling cost something real.",
                illustrationName: "walk-to-unlock",
                onNext: advanceStep
            )
            .transition(contentTransition)
        
        case 2:
            HealthPermissionContent(onNext: advanceStep)
                .transition(contentTransition)
            
        case 3:
            UsageEstimateContent(
                onNext: { hours in
                    estimatedHours = hours
                    advanceStep()
                }
            )
            .transition(contentTransition)
            
        case 4:
            UsageImpactContent(
                hours: estimatedHours,
                illustrationName: "x-days-in-a-year",
                onNext: advanceStep
            )
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
            
        case 5:
            ScreenTimePermissionContent(
                illustrationName: "confront-your-vices",
                onNext: advanceStep
            )
                .transition(contentTransition)
            
        case 6:
            AppPickerContent(onNext: advanceStep)
                .transition(contentTransition)
            
        case 7:
            // Final step - transition to Home
            Color.clear.onAppear {
                withAnimation(.smooth(duration: 0.5)) {
                    hasCompletedOnboarding = true
                }
            }
            
        default:
            EmptyView()
        }
    }
    
    private func advanceStep() {
        previousStep = step
        withAnimation(.smooth(duration: 0.4)) {
            step += 1
        }
    }
    
    /// Content-only transition - subtle, no movement to avoid jarring
    private var contentTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity.combined(with: .offset(y: -4))
        )
    }
}

// MARK: - Stable Background (Never Animates)

/// A single, stable background for all onboarding screens.
/// This prevents the "stuttering" effect when transitioning between views.
private struct OnboardingBackground: View {
    var body: some View {
        ZStack {
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                ZenoSemanticTokens.Gradients.swampBody
                    .overlay(
                        ZenoSemanticTokens.Gradients.deepVoid
                            .opacity(0.8)
                    )
                    .frame(height: proxy.size.height * 0.6)
                    .mask(
                        LinearGradient(
                            colors: [.black, .black, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea()
            
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
        }
    }
}

// MARK: - Content-Only Views (No Background)

/// Generic onboarding content view (for explainer screens)
private struct OnboardingContentView: View {
    let title: String
    let description: String
    var illustrationName: String? = nil
    let onNext: () -> Void
    
    @State private var contentVisible = false
    
    /// Stagger offset: if illustration exists, text starts at index 1
    private var textStartIndex: Int { illustrationName != nil ? 1 : 0 }
    
    var body: some View {
        VStack(spacing: 0) {
            // Illustration (if provided) with ambient animation
            if let illustrationName = illustrationName {
                illustrationView(for: illustrationName)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.42)
                    .staggeredItem(index: 0, isVisible: contentVisible)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                Text(title)
                    .font(ZenoTokens.Typography.displayXSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: textStartIndex, isVisible: contentVisible)
                
                Text(description)
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, ZenoSemanticTokens.Space.xl)
                    .staggeredItem(index: textStartIndex + 1, isVisible: contentVisible)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ActionButton("Next", variant: .primary, action: onNext)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
                .staggeredItem(index: textStartIndex + 2, isVisible: contentVisible)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
    
    /// Try to load SVG from bundle (no subdirectory - SVGs at bundle root)
    @ViewBuilder
    private func illustrationView(for name: String) -> some View {
        if let url = svgURL(named: name) {
            // Found SVG in bundle - use animated version
            AnimatedIllustration(url: url)
        } else {
            // Fallback: simple ambient glow placeholder when SVG not found
            IllustrationPlaceholder()
        }
    }
}

// MARK: - Illustration Placeholder (Fallback)

/// Minimal fallback when SVG files aren't in the bundle - shows ambient glow
private struct IllustrationPlaceholder: View {
    private enum Config {
        static let glowMin: Double = 0.15
        static let glowMax: Double = 0.3
        static let glowSpeed: Double = 0.4
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let glowPhase = sin(time * Config.glowSpeed * .pi * 2)
            let glowOpacity = Config.glowMin + (Config.glowMax - Config.glowMin) * ((glowPhase + 1) / 2)
            
            // Ambient glow only - no broken image reference
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZenoTokens.ColorBase.Acid._400.opacity(glowOpacity),
                            ZenoTokens.ColorBase.Sand._500.opacity(glowOpacity * 0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 50)
        }
    }
}

// MARK: - Animated Illustration (Ambient Loops)

/// Wraps an SVG illustration with ambient loop animations.
/// Creates a "living" feel without being distracting.
private struct AnimatedIllustration: View {
    let url: URL
    
    var body: some View {
        // Check if this is the zen-svg-1 illustration (has layered version)
        if url.lastPathComponent == "zen-svg-1.svg" {
            LayeredZenIllustration(fallbackURL: url)
        } else if LayeredGenericIllustration.hasLayers(for: url.deletingPathExtension().lastPathComponent) {
            LayeredGenericIllustration(
                baseName: url.deletingPathExtension().lastPathComponent,
                fallbackURL: url
            )
        } else {
            // Fallback for other SVGs
            SimpleAnimatedSVG(url: url)
        }
    }
}

// MARK: - Layered Zen Illustration (Independent Layer Animations)

/// The main zen illustration with each layer animated independently.
/// Falls back to simple animation if layer SVGs aren't available.
private struct LayeredZenIllustration: View {
    let fallbackURL: URL
    
    // Check if layered SVGs are available (try with and without subdirectory)
    private var hasLayers: Bool {
        layerURL(for: "zen-svg-1-figure") != nil
    }
    
    // Helper to find layer SVG (tries subdirectory first, then root)
    private func layerURL(for name: String) -> URL? {
        svgURL(
            named: name,
            preferredSubdirectories: [
                "SVGs/zen-svg-1",
                "zen-svg-1",
                "SVGs",
                nil
            ]
        )
    }
    
    // MARK: Animation Configuration per Layer
    private enum Config {
        // RAYS: Slow rotation pulse (very subtle)
        static let raysPulseScale: CGFloat = 0.012
        static let raysPulseSpeed: Double = 0.3
        static let raysRotation: Double = 0.8
        static let raysRotationSpeed: Double = 0.1
        
        // HALO: Gentle breathing scale
        static let haloBreathScale: CGFloat = 0.006
        static let haloBreathSpeed: Double = 0.4
        
        // CLOUDS: Horizontal drift
        static let cloudDriftX: CGFloat = 2.5
        static let cloudDriftSpeed: Double = 0.2
        
        // FIGURE: Subtle breathing
        static let figureBreathScale: CGFloat = 0.003
        static let figureBreathSpeed: Double = 0.5
        static let figureFloatY: CGFloat = 1.2
        static let figureFloatSpeed: Double = 0.3
        
        // PALMS: Gentle sway
        static let palmSwayRotation: Double = 0.6
        static let palmSwaySpeed: Double = 0.25
        
        // PATTERNS: Opacity pulse (subtle shimmer)
        static let patternOpacityMin: Double = 0.92
        static let patternOpacityMax: Double = 1.0
        static let patternPulseSpeed: Double = 0.5
        
        // GLOW: Behind halo
        static let glowOpacityMin: Double = 0.15
        static let glowOpacityMax: Double = 0.25
        static let glowPulseSpeed: Double = 0.4
    }
    
    var body: some View {
        if hasLayers {
            layeredContent
        } else {
            // Fallback: use the combined SVG with simple animation
            SimpleAnimatedSVG(url: fallbackURL)
        }
    }
    
    @ViewBuilder
    private var layeredContent: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            // === Calculate all animation phases ===
            let raysPulse = sin(time * Config.raysPulseSpeed * .pi * 2)
            let raysRotate = sin(time * Config.raysRotationSpeed * .pi * 2)
            let raysScale = 1.0 + (Config.raysPulseScale * raysPulse)
            let raysAngle = Config.raysRotation * raysRotate
            
            let haloBreath = sin(time * Config.haloBreathSpeed * .pi * 2)
            let haloScale = 1.0 + (Config.haloBreathScale * haloBreath)
            
            let cloudDrift = sin(time * Config.cloudDriftSpeed * .pi * 2)
            let cloudOffsetX = Config.cloudDriftX * cloudDrift
            
            let figureBreath = sin(time * Config.figureBreathSpeed * .pi * 2)
            let figureFloat = sin(time * Config.figureFloatSpeed * .pi * 2)
            let figureScale = 1.0 + (Config.figureBreathScale * figureBreath)
            let figureOffsetY = Config.figureFloatY * figureFloat
            
            let palmSway = sin(time * Config.palmSwaySpeed * .pi * 2)
            let palmRotation = Config.palmSwayRotation * palmSway
            
            let patternPulse = sin(time * Config.patternPulseSpeed * .pi * 2)
            let patternOpacity = Config.patternOpacityMin + (Config.patternOpacityMax - Config.patternOpacityMin) * ((patternPulse + 1) / 2)
            
            let glowPulse = sin(time * Config.glowPulseSpeed * .pi * 2)
            let glowOpacity = Config.glowOpacityMin + (Config.glowOpacityMax - Config.glowOpacityMin) * ((glowPulse + 1) / 2)
            
            // === Compose layers ===
            ZStack {
                // Layer 0: GLOW
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZenoTokens.ColorBase.Acid._400.opacity(glowOpacity),
                                ZenoTokens.ColorBase.Sand._500.opacity(glowOpacity * 0.5),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 180
                        )
                    )
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(y: -80)
                
                if let raysURL = layerURL(for: "zen-svg-1-rays") {
                    SVGView(contentsOf: raysURL)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(raysScale)
                        .rotationEffect(.degrees(raysAngle))
                }
                
                if let haloURL = layerURL(for: "zen-svg-1-halo") {
                    SVGView(contentsOf: haloURL)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(haloScale)
                }
                
                if let cloudsURL = layerURL(for: "zen-svg-1-clouds") {
                    SVGView(contentsOf: cloudsURL)
                        .aspectRatio(contentMode: .fit)
                        .offset(x: cloudOffsetX)
                }
                
                if let palmsURL = layerURL(for: "zen-svg-1-palms") {
                    SVGView(contentsOf: palmsURL)
                        .aspectRatio(contentMode: .fit)
                        .rotationEffect(.degrees(palmRotation), anchor: .bottom)
                }
                
                if let patternsURL = layerURL(for: "zen-svg-1-patterns") {
                    SVGView(contentsOf: patternsURL)
                        .aspectRatio(contentMode: .fit)
                        .opacity(patternOpacity)
                }
                
                if let groundURL = layerURL(for: "zen-svg-1-ground") {
                    SVGView(contentsOf: groundURL)
                        .aspectRatio(contentMode: .fit)
                }
                
                if let figureURL = layerURL(for: "zen-svg-1-figure") {
                    SVGView(contentsOf: figureURL)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(figureScale)
                        .offset(y: figureOffsetY)
                }
            }
        }
    }
}

// MARK: - Layered Generic Illustration (4–5 layers)

/// Generic layered renderer used for other onboarding illustrations.
/// Expects assets named `<base>-background.svg`, `<base>-accent.svg`,
/// `<base>-figure.svg`, `<base>-foreground.svg` (optional) inside either
/// `SVGs/<base>/` or the bundle root, and gracefully falls back if any layer
/// is missing.
private struct LayeredGenericIllustration: View {
    let baseName: String
    let fallbackURL: URL
    
    private enum Config {
        static let breatheScale: CGFloat = 0.012
        static let breatheSpeed: Double = 0.55
        static let floatOffset: CGFloat = 5
        static let floatSpeed: Double = 0.35
        
        static let accentOpacityMin: Double = 0.9
        static let accentOpacityMax: Double = 1.0
        static let accentPulseSpeed: Double = 0.45
        
        static let glowOpacityMin: Double = 0.12
        static let glowOpacityMax: Double = 0.28
        static let glowPulseSpeed: Double = 0.4
    }
    
    static func hasLayers(for baseName: String) -> Bool {
        layerURL(for: baseName, suffix: "figure") != nil
    }
    
    private var hasAnyLayer: Bool {
        layerURL(for: "figure") != nil ||
        layerURL(for: "background") != nil ||
        layerURL(for: "accent") != nil ||
        layerURL(for: "foreground") != nil
    }
    
    var body: some View {
        if hasAnyLayer {
            layeredContent
        } else {
            SimpleAnimatedSVG(url: fallbackURL)
        }
    }
    
    @ViewBuilder
    private var layeredContent: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            let breathePhase = sin(time * Config.breatheSpeed * .pi * 2)
            let floatPhase = sin(time * Config.floatSpeed * .pi * 2)
            let accentPhase = sin(time * Config.accentPulseSpeed * .pi * 2)
            let glowPhase = sin(time * Config.glowPulseSpeed * .pi * 2)
            
            let figureScale = 1.0 + (Config.breatheScale * breathePhase)
            let figureOffsetY = Config.floatOffset * floatPhase
            
            let accentOpacity = Config.accentOpacityMin + (Config.accentOpacityMax - Config.accentOpacityMin) * ((accentPhase + 1) / 2)
            let glowOpacity = Config.glowOpacityMin + (Config.glowOpacityMax - Config.glowOpacityMin) * ((glowPhase + 1) / 2)
            
            ZStack {
                // Ambient glow behind everything
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZenoTokens.ColorBase.Acid._400.opacity(glowOpacity),
                                ZenoTokens.ColorBase.Sand._500.opacity(glowOpacity * 0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 16,
                            endRadius: 200
                        )
                    )
                    .frame(width: 320, height: 320)
                    .blur(radius: 55)
                    .offset(y: -50)
                
                if let backgroundURL = layerURL(for: "background") {
                    SVGView(contentsOf: backgroundURL)
                        .aspectRatio(contentMode: .fit)
                }
                
                if let accentURL = layerURL(for: "accent") {
                    SVGView(contentsOf: accentURL)
                        .aspectRatio(contentMode: .fit)
                        .opacity(accentOpacity)
                }
                
                if let figureURL = layerURL(for: "figure") {
                    SVGView(contentsOf: figureURL)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(figureScale)
                        .offset(y: figureOffsetY)
                }
                
                if let foregroundURL = layerURL(for: "foreground") {
                    SVGView(contentsOf: foregroundURL)
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
    
    private func layerURL(for suffix: String) -> URL? {
        Self.layerURL(for: baseName, suffix: suffix)
    }
    
    private static func layerURL(for baseName: String, suffix: String) -> URL? {
        svgURL(
            named: "\(baseName)-\(suffix)",
            preferredSubdirectories: [
                "SVGs/\(baseName)",
                baseName,
                "SVGs",
                nil
            ]
        )
    }
}

// MARK: - Simple Animated SVG (Fallback for non-layered illustrations)

/// For SVGs that don't have layered versions, apply simple unified animation.
private struct SimpleAnimatedSVG: View {
    let url: URL
    
    private enum Config {
        static let breatheScale: CGFloat = 0.02
        static let breatheSpeed: Double = 0.8
        static let floatOffset: CGFloat = 8
        static let floatSpeed: Double = 0.5
        static let glowMin: Double = 0.15
        static let glowMax: Double = 0.4
        static let glowSpeed: Double = 0.6
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            let breathePhase = sin(time * Config.breatheSpeed * .pi * 2)
            let floatPhase = sin(time * Config.floatSpeed * .pi * 2)
            let glowPhase = sin(time * Config.glowSpeed * .pi * 2)
            
            let scale = 1.0 + (Config.breatheScale * breathePhase)
            let yOffset = Config.floatOffset * floatPhase
            let glowOpacity = Config.glowMin + (Config.glowMax - Config.glowMin) * ((glowPhase + 1) / 2)
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZenoTokens.ColorBase.Acid._400.opacity(glowOpacity),
                                ZenoTokens.ColorBase.Acid._400.opacity(glowOpacity * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(y: -60)
                
                SVGView(contentsOf: url)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(y: yOffset)
            }
        }
    }
}

// MARK: - SVG Bundle Lookup Helper

/// Resolves SVG URLs with awareness of the bundled `SVGs/` folder reference.
/// Tries subdirectories in order and falls back to the bundle root.
private func svgURL(
    named name: String,
    preferredSubdirectories: [String?] = [
        // Common folder-reference locations we use in the app bundle
        "SVGs",
        "Zeno/Resources/SVGs",
        "Resources/SVGs",
        "Resources",
        nil
    ]
) -> URL? {
    for subdirectory in preferredSubdirectories {
        if let url = Bundle.main.url(forResource: name, withExtension: "svg", subdirectory: subdirectory) {
            return url
        }
    }
    
    // Fallback: deep search in bundle for the file (handles unknown folder structures)
    if let root = Bundle.main.resourceURL {
        let fm = FileManager.default
        if let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if fileURL.lastPathComponent == "\(name).svg" {
#if DEBUG
                    print("ℹ️ SVG found via deep search: \(fileURL.path)")
#endif
                    return fileURL
                }
            }
        }
    }
    
#if DEBUG
    print("⚠️ SVG not found: \(name)")
#endif
    return nil
}

#Preview {
    OnboardingFlowView(hasCompletedOnboarding: .constant(false))
}
