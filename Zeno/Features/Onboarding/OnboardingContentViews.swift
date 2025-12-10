import SwiftUI
import FamilyControls
import SVGView

// MARK: - Health Permission Content (No Background)

struct HealthPermissionContent: View {
    @State private var viewModel = HealthPermissionViewModel()
    @State private var contentVisible = false
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                // Education Visual (Shown when Idle)
                if case .idle = viewModel.state {
                    educationVisual
                        .padding(.bottom, ZenoSemanticTokens.Space.lg)
                        .staggeredItem(index: 0, isVisible: contentVisible)
                }
                
                Text(titleText)
                    .font(ZenoTokens.Typography.displayXSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 1, isVisible: contentVisible)
                
                Text(descriptionText)
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 2, isVisible: contentVisible)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
            
            ActionButton(ctaText, variant: .primary, isLoading: isLoading, action: handleAction)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
                .staggeredItem(index: 3, isVisible: contentVisible)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
    
    @ViewBuilder
    private var educationVisual: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            Text("The Exchange Rate")
                .font(ZenoTokens.Typography.labelLarge)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .textCase(.uppercase)
            
            HStack(alignment: .firstTextBaseline, spacing: ZenoSemanticTokens.Space.sm) {
                Text("1,000")
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                Text("steps")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            
            Image(systemName: "arrow.down")
                .font(.title2)
                .foregroundColor(ZenoSemanticTokens.Theme.accentForeground)
                .padding(.vertical, ZenoSemanticTokens.Space.xs)
            
            HStack(alignment: .firstTextBaseline, spacing: ZenoSemanticTokens.Space.sm) {
                Text("10")
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
                Text("minutes")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
            }
        }
    }
    
    private var isLoading: Bool {
        if case .requesting = viewModel.state { return true }
        return false
    }
    
    private var titleText: String {
        switch viewModel.state {
        case .authorized: return "Baseline Established"
        default: return "Measure Your Steps"
        }
    }
    
    private var descriptionText: String {
        switch viewModel.state {
        case .authorized:
            return "Your average of \(viewModel.averageSteps) steps unlocks \(viewModel.potentialCredits) minutes of scrolling per day. To use more, you must walk more."
        case .error:
            return "We encountered an issue connecting to Health. Please ensure Zeno has permission in Settings."
        default:
            return "Zeno uses your daily step count to unlock apps. Give access to set your baseline."
        }
    }
    
    private var ctaText: String {
        switch viewModel.state {
        case .authorized: return "Continue"
        case .error: return "Open Settings"
        default: return "Connect Health"
        }
    }
    
    private func handleAction() {
        switch viewModel.state {
        case .idle:
            Task { await viewModel.requestAccess() }
        case .authorized:
            onNext()
        case .denied, .error:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .requesting:
            break
        }
    }
}

// MARK: - Usage Estimate Content (No Background)

struct UsageEstimateContent: View {
    let onNext: (Int) -> Void
    @State private var contentVisible = false
    
    private let options = [
        (text: "Under 1 hour", value: 1),
        (text: "1-3 hours", value: 2),
        (text: "3-4 hours", value: 4),
        (text: "4-5 hours", value: 5),
        (text: "5-7 hours", value: 6),
        (text: "More than 7 hours", value: 8)
    ]
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.lg) {
            VStack(spacing: ZenoSemanticTokens.Space.sm) {
                Text("Estimate Your Usage")
                    .font(ZenoTokens.Typography.labelLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .staggeredItem(index: 0, isVisible: contentVisible)
                
                Text("How much time do you think you spend on your phone daily?")
                    .font(ZenoTokens.Typography.titleMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 1, isVisible: contentVisible)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .padding(.top, ZenoSemanticTokens.Space.xl)
            
            ScrollView {
                VStack(spacing: ZenoSemanticTokens.Space.md) {
                    ForEach(Array(options.enumerated()), id: \.element.text) { index, option in
                        Button(action: { onNext(option.value) }) {
                            Text(option.text)
                                .font(ZenoTokens.Typography.bodyLarge)
                                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, ZenoSemanticTokens.Space.lg)
                                .background(ZenoSemanticTokens.Theme.card)
                                .cornerRadius(ZenoSemanticTokens.Radius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                                        .stroke(ZenoSemanticTokens.Theme.border, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .staggeredItem(index: index + 2, isVisible: contentVisible)
                    }
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
}

// MARK: - Usage Impact Content (No Background)

struct UsageImpactContent: View {
    let hours: Int
    var illustrationName: String? = nil
    let onNext: () -> Void
    @State private var contentVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let illustrationName {
                OnboardingIllustration(name: illustrationName)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.36)
                    .staggeredItem(index: 0, isVisible: contentVisible)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.lg) {
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
                    Text("\(calculateDays()) days")
                        .font(ZenoTokens.Typography.displayXSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.destructive)
                        .staggeredItem(index: 1, isVisible: contentVisible)
                    
                    Text("a year.")
                        .font(ZenoTokens.Typography.displayXSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .staggeredItem(index: 2, isVisible: contentVisible)
                }
                
                Text("That is how much of your life disappears into a screen based on your estimate.")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 3, isVisible: contentVisible)
                
                Callout(
                    icon: "clock.arrow.circlepath",
                    text: "Time is the only resource you can never get back.",
                    variant: .info
                )
                .padding(.top, ZenoSemanticTokens.Space.sm)
                .staggeredItem(index: 4, isVisible: contentVisible)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
            
            ActionButton("Confront It", variant: .primary, action: onNext)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
                .staggeredItem(index: 5, isVisible: contentVisible)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                contentVisible = true
            }
        }
    }
    
    private func calculateDays() -> Int {
        Int((Double(hours) * 365.0 / 24.0).rounded())
    }
}

// MARK: - Screen Time Permission Content (No Background)

struct ScreenTimePermissionContent: View {
    var illustrationName: String? = nil
    @State private var viewModel = ScreenTimePermissionViewModel()
    @State private var contentVisible = false
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if let illustrationName {
                OnboardingIllustration(name: illustrationName)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.36)
                    .staggeredItem(index: 0, isVisible: contentVisible)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                Text("Confront Your Vices")
                    .font(ZenoTokens.Typography.displayXSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 1, isVisible: contentVisible)
                
                Text("Let's take action. Zeno needs access to block distracting apps and help you break the cycle.")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 2, isVisible: contentVisible)
                
                Callout(
                    icon: "lock.shield.fill",
                    text: "Your data stays on-device. Zeno cannot see your messages or content.",
                    variant: .info
                )
                .padding(.top, ZenoSemanticTokens.Space.sm)
                .staggeredItem(index: 3, isVisible: contentVisible)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
            
            ActionButton(ctaText, variant: .primary, isLoading: viewModel.isRequesting, action: handleAction)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
                .staggeredItem(index: 4, isVisible: contentVisible)
        }
        .task {
            await viewModel.checkStatus()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
    
    private var ctaText: String {
        switch viewModel.status {
        case .approved: return "Continue"
        case .denied: return "Open Settings"
        default: return "Connect Screen Time"
        }
    }
    
    private func handleAction() {
        if viewModel.status == .approved {
            onNext()
        } else if viewModel.status == .denied {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } else {
            Task {
                await viewModel.requestAuthorization()
                if viewModel.status == .approved {
                    onNext()
                }
            }
        }
    }
}

// MARK: - App Picker Content (No Background)

struct AppPickerContent: View {
    let onNext: () -> Void
    
    @State private var viewModel = AppPickerViewModel()
    @State private var isPickerPresented = false
    @State private var contentVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: ZenoSemanticTokens.Space.lg) {
                    Spacer()
                        .frame(height: ZenoSemanticTokens.Space.xxl)
                    
                    // Header
                    VStack(spacing: ZenoSemanticTokens.Space.md) {
                        Text("Select Your Apps")
                            .font(ZenoTokens.Typography.titleMedium)
                            .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .staggeredItem(index: 0, isVisible: contentVisible)
                        
                        Text("Choose the apps that distract you the most. Zeno will block them until you earn access.")
                            .font(ZenoTokens.Typography.bodyLarge)
                            .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .staggeredItem(index: 1, isVisible: contentVisible)
                    }
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    
                    // Blocked Apps Selection Row
                    SelectionRow(
                        icon: "apps.iphone",
                        title: "Blocked Apps",
                        subtitle: viewModel.selectedCount > 0 ? "\(viewModel.selectedCount) apps selected" : "Tap to select",
                        action: { isPickerPresented = true }
                    )
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .familyActivityPicker(isPresented: $isPickerPresented, selection: $viewModel.selection)
                    .staggeredItem(index: 2, isVisible: contentVisible)
                    
                    // MARK: - Blocking Schedule Section
                    scheduleSection
                        .staggeredItem(index: 3, isVisible: contentVisible)
                    
                    // Bottom spacing for scroll content
                    Spacer()
                        .frame(height: 120)
                }
            }
            
            // Footer with gradient overlay
            VStack {
                ActionButton("Continue", variant: .primary, action: saveAndContinue)
                    .disabled(viewModel.selectedCount == 0 || !viewModel.isScheduleValid)
                    .opacity((viewModel.selectedCount == 0 || !viewModel.isScheduleValid) ? 0.5 : 1.0)
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
                    .staggeredItem(index: 6, isVisible: contentVisible)
            }
            .background(
                LinearGradient(
                    colors: [
                        ZenoSemanticTokens.Theme.background.opacity(0),
                        ZenoSemanticTokens.Theme.background.opacity(0.9),
                        ZenoSemanticTokens.Theme.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .allowsHitTesting(false),
                alignment: .top
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
    
    // MARK: - Schedule Section
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            // Section Header
            ZenoSectionHeader("BLOCKING SCHEDULE")
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            
            // Time Picker Cards
            ScheduleTimeStack(
                startTime: $viewModel.scheduleStartTime,
                endTime: $viewModel.scheduleEndTime
            )
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            
            // Days Section Header
            ZenoSectionHeader("BLOCKING DAYS")
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.top, ZenoSemanticTokens.Space.sm)
            
            // Day Chips
            DayChipRow(activeDays: $viewModel.activeDays)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
        }
    }
    
    private func saveAndContinue() {
        viewModel.saveSelection()
        AppBlockingService.shared.blockApps()
        onNext()
    }
}


// MARK: - Shared Illustration (Ambient)

private struct OnboardingIllustration: View {
    let name: String
    
    // TODO: Re-enable layered animations after SVG layer rework
    // All SVGs that have layered animations (currently disabled)
    // private static let layeredSVGs = ["zen-svg-1", "walk-to-unlock", "x-days-in-a-year", "confront-your-vices"]
    
    var body: some View {
        let resolvedURL = svgURL(named: name)
        
        // TEMPORARILY DISABLED: Using static SVGs for all onboarding screens
        // The layered animations need SVG rework to display correctly.
        // Uncomment below when layers are properly split.
        
        /*
        if let url = resolvedURL {
            if Self.layeredSVGs.contains(name), ContentLayeredIllustration.hasLayers(for: name) {
                // Use layered animation for all supported SVGs
                ContentLayeredIllustration(baseName: name, fallbackURL: url)
            } else {
                // Static for non-layered illustrations
                StaticSVGForOnboarding(url: url)
            }
        } else {
            IllustrationGlowFallback()
        }
        */
        
        // Static SVG for now
        if let url = resolvedURL {
            StaticSVGForOnboarding(url: url)
        } else {
            IllustrationGlowFallback()
        }
    }
}

// MARK: - Layered Illustration (Onboarding screens)

/// Four-layer animation renderer for onboarding content screens.
/// Each layer animates independently: background, accent, figure, foreground.
/// Matches the animation style from LayeredGenericIllustration.
private struct ContentLayeredIllustration: View {
    let baseName: String
    let fallbackURL: URL
    
    private enum Config {
        // BACKGROUND: Breathing + drift + opacity pulse (very noticeable)
        static let bgBreathScale: CGFloat = 0.015
        static let bgBreathSpeed: Double = 0.35
        static let bgDriftX: CGFloat = 4.0
        static let bgDriftSpeed: Double = 0.2
        static let bgOpacityMin: Double = 0.85
        static let bgOpacityMax: Double = 1.0
        static let bgOpacitySpeed: Double = 0.3
        
        // ACCENT: Opacity + scale pulse (neon energy effect)
        static let accentOpacityMin: Double = 0.7
        static let accentOpacityMax: Double = 1.0
        static let accentPulseSpeed: Double = 0.5
        static let accentScaleMin: CGFloat = 0.99
        static let accentScaleMax: CGFloat = 1.015
        
        // FIGURE: Breathing + float
        static let figureBreathScale: CGFloat = 0.012
        static let figureBreathSpeed: Double = 0.4
        static let figureFloatOffset: CGFloat = 4
        static let figureFloatSpeed: Double = 0.25
        
        // FOREGROUND: Subtle opacity shimmer
        static let fgOpacityMin: Double = 0.85
        static let fgOpacityMax: Double = 1.0
        static let fgPulseSpeed: Double = 0.45
        
        // AMBIENT GLOW: Behind everything
        static let glowOpacityMin: Double = 0.15
        static let glowOpacityMax: Double = 0.35
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
            StaticSVGForOnboarding(url: fallbackURL)
        }
    }
    
    @ViewBuilder
    private var layeredContent: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            // === Calculate animation phases for each layer ===
            
            // Background: breathing + drift + opacity
            let bgBreathPhase = sin(time * Config.bgBreathSpeed * .pi * 2)
            let bgDriftPhase = sin(time * Config.bgDriftSpeed * .pi * 2)
            let bgOpacityPhase = sin(time * Config.bgOpacitySpeed * .pi * 2)
            let bgScale = 1.0 + (Config.bgBreathScale * bgBreathPhase)
            let bgOffsetX = Config.bgDriftX * bgDriftPhase
            let bgOpacity = Config.bgOpacityMin + (Config.bgOpacityMax - Config.bgOpacityMin) * ((bgOpacityPhase + 1) / 2)
            
            // Accent: opacity + scale pulse (neon energy)
            let accentPhase = sin(time * Config.accentPulseSpeed * .pi * 2)
            let accentOpacity = Config.accentOpacityMin + (Config.accentOpacityMax - Config.accentOpacityMin) * ((accentPhase + 1) / 2)
            let accentScale = Config.accentScaleMin + (Config.accentScaleMax - Config.accentScaleMin) * ((accentPhase + 1) / 2)
            
            // Figure: breathing + floating
            let figureBreathPhase = sin(time * Config.figureBreathSpeed * .pi * 2)
            let figureFloatPhase = sin(time * Config.figureFloatSpeed * .pi * 2)
            let figureScale = 1.0 + (Config.figureBreathScale * figureBreathPhase)
            let figureOffsetY = Config.figureFloatOffset * figureFloatPhase
            
            // Foreground: subtle opacity shimmer
            let fgPulsePhase = sin(time * Config.fgPulseSpeed * .pi * 2)
            let fgOpacity = Config.fgOpacityMin + (Config.fgOpacityMax - Config.fgOpacityMin) * ((fgPulsePhase + 1) / 2)
            
            // Ambient glow
            let glowPhase = sin(time * Config.glowPulseSpeed * .pi * 2)
            let glowOpacity = Config.glowOpacityMin + (Config.glowOpacityMax - Config.glowOpacityMin) * ((glowPhase + 1) / 2)
            
            // === Compose layers (each animated independently) ===
            // Order: Glow → Background → Accent → Figure → Foreground
            ZStack {
                // Layer 0: Ambient glow (behind everything)
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
                
                // Layer 1: Figure (golden statue - base)
                if let figureURL = layerURL(for: "figure") {
                    SVGView(contentsOf: figureURL)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(figureScale)
                        .offset(y: figureOffsetY)
                }
                
                // Layer 2: Background (pinkish shadows - overlay above figure)
                if let backgroundURL = layerURL(for: "background") {
                    SVGView(contentsOf: backgroundURL)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(bgScale)
                        .offset(x: bgOffsetX)
                        .opacity(bgOpacity * 0.6) // Reduced opacity for overlay effect
                        .blendMode(.multiply)
                }
                
                // Layer 3: Accent (wavy neon lines)
                if let accentURL = layerURL(for: "accent") {
                    SVGView(contentsOf: accentURL)
                        .aspectRatio(contentMode: .fit)
                        .opacity(accentOpacity)
                        .scaleEffect(accentScale)
                }
                
                // Layer 4: Foreground (white highlights - topmost)
                if let foregroundURL = layerURL(for: "foreground") {
                    SVGView(contentsOf: foregroundURL)
                        .aspectRatio(contentMode: .fit)
                        .opacity(fgOpacity)
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

// Static rendering for non-zen onboarding illustrations
private struct StaticSVGForOnboarding: View {
    let url: URL
    
    var body: some View {
        SVGView(contentsOf: url)
            .aspectRatio(contentMode: .fit)
    }
}

private struct IllustrationGlowFallback: View {
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

// MARK: - SVG Bundle Lookup Helper

/// Resolves SVG URLs when the `SVGs/` folder is copied as a folder reference.
/// Attempts subdirectories in order, then falls back to the bundle root.
private func svgURL(
    named name: String,
    preferredSubdirectories: [String?] = [
        // Common folder-reference locations we use in the app bundle
        nil,
        "SVGs",
        "Zeno/Resources/SVGs",
        "Resources/SVGs",
        "Resources"
    ]
) -> URL? {
    // Expand with name-specific folders at call time to avoid referencing
    // another parameter from the default argument.
    let searchOrder = preferredSubdirectories.flatMap { base -> [String?] in
        guard let base else { return [nil] }
        return [base, "\(base)/\(name)"]
    }
    
    for subdirectory in searchOrder {
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
                    return fileURL
                }
            }
        }
    }
    
    return nil
}


