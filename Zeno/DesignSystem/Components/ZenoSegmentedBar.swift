import SwiftUI

// MARK: - Segmented Bar Animation Mode

/// Animation mode for the segmented bar.
/// Choose based on use case to get the right feel.
enum SegmentedBarAnimationMode {
    /// Smooth liquid fill from left-to-right on EVERY appear.
    /// Starts empty, then fills. Perfect for static progress displays (Home card).
    case liquidReveal
    
    /// Smooth animation when progress changes.
    /// Already-filled segments stay visible. Perfect for live step tracking (Walk page).
    case liquidFlow
    
    /// No animation. Instant fill.
    case none
}

/// A segmented progress bar with individual bars and smooth liquid-mask animation.
/// Matches the Zeno mechanical aesthetic with discrete segments, but animates
/// as a single fluid motion rather than individual segment pops.
///
/// **Animation Modes:**
/// - `.liquidReveal` — Smooth fill from 0 on every appear (Home card toggle)
/// - `.liquidFlow` — Smooth animation on progress changes (Live step tracking)
/// - `.none` — No animation
///
/// **Usage:**
/// ```swift
/// // Home card (toggle between steps/time) — animates from 0 every time
/// ZenoSegmentedBar(progress: 0.75, animationMode: .liquidReveal)
///
/// // Live step tracking — smooth progress updates
/// ZenoSegmentedBar(progress: stepProgress, animationMode: .liquidFlow)
/// ```
struct ZenoSegmentedBar: View {
    /// Progress value between 0 and 1
    let progress: CGFloat
    
    /// Number of segments to display
    let segmentCount: Int
    
    /// Height of each segment
    let height: CGFloat
    
    /// Color for filled segments
    let filledColor: Color
    
    /// Color for empty segments
    let emptyColor: Color
    
    /// Animation mode
    let animationMode: SegmentedBarAnimationMode
    
    /// The animated progress value (what the mask actually uses)
    @State private var animatedProgress: CGFloat = 0
    
    init(
        progress: CGFloat,
        segmentCount: Int = 40,
        height: CGFloat = ZenoTokens.SpacingScale._4, // 16pt
        filledColor: Color = ZenoSemanticTokens.Theme.primary,
        emptyColor: Color = ZenoTokens.ColorBase.Moss._600,
        animationMode: SegmentedBarAnimationMode = .liquidReveal
    ) {
        self.progress = min(max(progress, 0), 1)
        self.segmentCount = segmentCount
        self.height = height
        self.filledColor = filledColor
        self.emptyColor = emptyColor
        self.animationMode = animationMode
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // MARK: - Empty Segments (Background)
                segmentsView(geometry: geometry, filled: false)
                
                // MARK: - Filled Segments (Masked by animated progress)
                segmentsView(geometry: geometry, filled: true)
                    .mask(
                        Rectangle()
                            .frame(width: geometry.size.width * animatedProgress)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )
            }
        }
        .frame(height: height)
        .onAppear {
            handleAppear()
        }
        .onChange(of: progress) { _, newValue in
            handleProgressChange(to: newValue)
        }
    }
    
    // MARK: - Segments View
    
    /// Creates the row of segment rectangles
    private func segmentsView(geometry: GeometryProxy, filled: Bool) -> some View {
        HStack(spacing: segmentSpacing(for: geometry.size.width)) {
            ForEach(0..<segmentCount, id: \.self) { _ in
                RoundedRectangle(cornerRadius: segmentCornerRadius)
                    .fill(filled ? filledColor : emptyColor)
                    .frame(
                        width: segmentWidth(for: geometry.size.width),
                        height: height
                    )
            }
        }
    }
    
    // MARK: - Animation Handlers
    
    /// Animation for progress bar fill — smooth easeInOut at medium speed (0.5s)
    /// Faster than `liquid` (0.8s) but still fluid, not jarring.
    private var fillAnimation: Animation {
        .easeInOut(duration: ZenoSemanticTokens.Motion.Duration.medium)
    }
    
    private func handleAppear() {
        switch animationMode {
        case .liquidReveal:
            // Start from 0, animate to progress
            animatedProgress = 0
            withAnimation(fillAnimation) {
                animatedProgress = progress
            }
            
        case .liquidFlow:
            // Start at current progress (no initial animation)
            animatedProgress = progress
            
        case .none:
            // Instant fill
            animatedProgress = progress
        }
    }
    
    private func handleProgressChange(to newValue: CGFloat) {
        switch animationMode {
        case .liquidReveal, .liquidFlow:
            // Smooth transition to new progress
            withAnimation(fillAnimation) {
                animatedProgress = newValue
            }
            
        case .none:
            // Instant update
            animatedProgress = newValue
        }
    }
    
    // MARK: - Layout Calculations
    
    /// Corner radius for each segment (square corners for mechanical aesthetic)
    private var segmentCornerRadius: CGFloat {
        ZenoSemanticTokens.Radius.none // 0pt - sharp, industrial
    }
    
    /// Calculate segment width based on available space
    private func segmentWidth(for totalWidth: CGFloat) -> CGFloat {
        let totalSpacing = segmentSpacing(for: totalWidth) * CGFloat(segmentCount - 1)
        let availableWidth = totalWidth - totalSpacing
        return availableWidth / CGFloat(segmentCount)
    }
    
    /// Calculate spacing between segments
    private func segmentSpacing(for totalWidth: CGFloat) -> CGFloat {
        // Spacing is ~25% of segment width for visual separation
        let estimatedSegmentWidth = totalWidth / CGFloat(segmentCount)
        return max(estimatedSegmentWidth * 0.25, ZenoTokens.SpacingScale._1) // 4pt min
    }
}

// MARK: - Preview

#Preview("Segmented Bar States") {
    VStack(spacing: ZenoSemanticTokens.Space.xl) {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("0%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("25%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0.25)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("50%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0.50)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("75%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0.75)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("100%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 1.0)
        }
    }
    .padding(ZenoSemanticTokens.Space.lg)
    .background(ZenoSemanticTokens.Theme.background)
}

#Preview("Segmented Bar Sizes") {
    VStack(spacing: ZenoSemanticTokens.Space.xl) {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Small (8pt, 30 segments)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0.7, segmentCount: 30, height: ZenoTokens.SpacingScale._2)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Default (16pt, 40 segments)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0.7)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Large (16pt, 50 segments)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0.7, segmentCount: 50, height: ZenoTokens.SpacingScale._4)
        }
    }
    .padding(ZenoSemanticTokens.Space.lg)
    .background(ZenoSemanticTokens.Theme.background)
}

#Preview("Segmented Bar Custom Colors") {
    VStack(spacing: ZenoSemanticTokens.Space.xl) {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Default (Acid + Moss)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(progress: 0.6)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Warning (Ember)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(
                progress: 0.3,
                filledColor: ZenoTokens.ColorBase.Ember._400,
                emptyColor: ZenoTokens.ColorBase.Ember._800
            )
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Danger (Clay)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoSegmentedBar(
                progress: 0.15,
                filledColor: ZenoTokens.ColorBase.Clay._400,
                emptyColor: ZenoTokens.ColorBase.Clay._800
            )
        }
    }
    .padding(ZenoSemanticTokens.Space.lg)
    .background(ZenoSemanticTokens.Theme.background)
}

// MARK: - Animation Previews

#Preview("Animation: Liquid Reveal") {
    LiquidRevealPreview()
}

#Preview("Animation: Liquid Flow (Live Tracking)") {
    LiveStepTrackingPreview()
}

/// Preview demonstrating liquid reveal animation.
/// Tap to reset and replay the animation.
private struct LiquidRevealPreview: View {
    @State private var showBar = false
    @State private var progress: CGFloat = 0.75
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.xl) {
            Text("Liquid Reveal Animation")
                .font(ZenoTokens.Typography.titleXSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            Text("Tap anywhere to replay")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            if showBar {
                ZenoSegmentedBar(progress: progress, animationMode: .liquidReveal)
            } else {
                // Placeholder to maintain layout
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: ZenoTokens.SpacingScale._4)
            }
            
            // Progress slider
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
                Text("Progress: \(Int(progress * 100))%")
                    .font(ZenoTokens.Typography.labelSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                
                Slider(value: $progress, in: 0...1)
                    .tint(ZenoSemanticTokens.Theme.primary)
            }
        }
        .padding(ZenoSemanticTokens.Space.lg)
        .background(ZenoSemanticTokens.Theme.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showBar = true
            }
        }
        .onTapGesture {
            // Reset and replay
            showBar = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showBar = true
            }
        }
    }
}

/// Preview simulating live step tracking.
/// Progress increases automatically, demonstrating liquid flow animation.
private struct LiveStepTrackingPreview: View {
    @State private var steps: Int = 0
    @State private var isWalking = false
    
    private let stepsPerMinute: Int = 100 // Steps needed for 1 minute
    private let maxSteps: Int = 100
    
    private var progress: CGFloat {
        CGFloat(steps) / CGFloat(maxSteps)
    }
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.xl) {
            Text("Liquid Flow (Live Tracking)")
                .font(ZenoTokens.Typography.titleXSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            // Step counter
            Text("\(steps) / \(maxSteps)")
                .font(ZenoTokens.Typography.monoDisplayMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap), value: steps)
            
            Text("steps to +1 min")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            // Progress bar with liquid flow animation for live tracking
            ZenoSegmentedBar(
                progress: progress,
                animationMode: .liquidFlow
            )
            
            // Simulate walking button
            Button(action: {
                isWalking.toggle()
                if isWalking {
                    startWalking()
                }
            }) {
                HStack(spacing: ZenoSemanticTokens.Space.sm) {
                    Image(systemName: isWalking ? "pause.fill" : "figure.walk")
                    Text(isWalking ? "Pause" : "Simulate Walking")
                }
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.primaryForeground)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.vertical, ZenoSemanticTokens.Space.md)
                .background(ZenoSemanticTokens.Theme.primary)
                .cornerRadius(ZenoSemanticTokens.Radius.sm)
            }
            
            // Reset button
            Button("Reset") {
                isWalking = false
                steps = 0
            }
            .font(ZenoTokens.Typography.labelSmall)
            .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
        .padding(ZenoSemanticTokens.Space.lg)
        .background(ZenoSemanticTokens.Theme.background)
    }
    
    private func startWalking() {
        guard isWalking, steps < maxSteps else {
            isWalking = false
            return
        }
        
        // Simulate steps coming in every 0.3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if isWalking && steps < maxSteps {
                steps += 3 // ~3 steps at a time
                startWalking() // Continue walking
            }
        }
    }
}
