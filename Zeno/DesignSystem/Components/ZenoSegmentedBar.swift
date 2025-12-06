import SwiftUI

// MARK: - Segmented Bar Animation Mode

/// Animation mode for the segmented bar.
/// Choose based on use case to get the right feel.
enum SegmentedBarAnimationMode {
    /// Stagger fill from left-to-right on EVERY appear (toggles, page changes).
    /// Starts empty, then fills. Perfect for static progress displays.
    case staggerEveryAppear
    
    /// Only animate NEW segments with a subtle grow effect.
    /// Already-filled segments stay static. Perfect for live step tracking.
    case incrementalOnly
    
    /// No animation. Instant fill.
    case none
}

// MARK: - Segmented Bar Animation Configuration

/// Configuration for segmented bar animations.
/// Follows Zeno animation guidelines — fast, purposeful, staggered.
enum SegmentedBarAnimationConfig {
    /// Minimal delay before first segment (just enough for empty state to render)
    static let renderDelay: Double = 0.05
    /// Delay between each segment's animation (fast wave)
    static let staggerInterval: Double = 0.012
    /// Easing curve for stagger reveal
    static let staggerEasing: Animation = .easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap)
    /// Easing curve for incremental segment updates
    static let incrementalEasing: Animation = .easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap)
}

/// A segmented progress bar with individual bars and smooth fill animations.
/// Matches the Zeno mechanical aesthetic with discrete segments.
///
/// **Animation Modes:**
/// - `.staggerEveryAppear` — Stagger fill on every appear (toggles, page changes)
/// - `.incrementalOnly` — Only new segments animate (live step tracking)
/// - `.none` — No animation
///
/// **Usage:**
/// ```swift
/// // Static display (toggle between steps/time) — animates every time
/// ZenoSegmentedBar(progress: 0.75, animationMode: .staggerEveryAppear)
///
/// // Live step tracking — only new segments pop
/// ZenoSegmentedBar(progress: stepProgress, animationMode: .incrementalOnly)
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
    
    /// Tracks which segments have been revealed (for animation)
    @State private var revealedSegments: Set<Int> = []
    
    /// Unique ID to force view refresh on appear (for staggerEveryAppear mode)
    @State private var refreshID = UUID()
    
    init(
        progress: CGFloat,
        segmentCount: Int = 40,
        height: CGFloat = ZenoTokens.SpacingScale._4, // 16pt
        filledColor: Color = ZenoSemanticTokens.Theme.primary,
        emptyColor: Color = ZenoTokens.ColorBase.Moss._600,
        animationMode: SegmentedBarAnimationMode = .staggerEveryAppear
    ) {
        self.progress = min(max(progress, 0), 1)
        self.segmentCount = segmentCount
        self.height = height
        self.filledColor = filledColor
        self.emptyColor = emptyColor
        self.animationMode = animationMode
    }
    
    /// Number of filled segments based on progress
    private var filledCount: Int {
        Int(round(progress * CGFloat(segmentCount)))
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: segmentSpacing(for: geometry.size.width)) {
                ForEach(0..<segmentCount, id: \.self) { index in
                    SegmentView(
                        index: index,
                        isFilled: index < filledCount,
                        isRevealed: revealedSegments.contains(index),
                        filledColor: filledColor,
                        emptyColor: emptyColor,
                        cornerRadius: segmentCornerRadius,
                        width: segmentWidth(for: geometry.size.width),
                        height: height,
                        animationMode: animationMode
                    )
                }
            }
        }
        .frame(height: height)
        .id(refreshID) // Force view refresh for staggerEveryAppear
        .onAppear {
            handleAppear()
        }
        .onChange(of: filledCount) { oldValue, newValue in
            handleProgressChange(from: oldValue, to: newValue)
        }
    }
    
    // MARK: - Animation Handlers
    
    private func handleAppear() {
        switch animationMode {
        case .staggerEveryAppear:
            // Reset and stagger fill from empty
            revealedSegments = []
            triggerStaggeredReveal(upTo: filledCount)
            
        case .incrementalOnly:
            // Instantly show current progress (no initial animation)
            revealedSegments = Set(0..<filledCount)
            
        case .none:
            // Instant fill
            revealedSegments = Set(0..<filledCount)
        }
    }
    
    private func handleProgressChange(from oldValue: Int, to newValue: Int) {
        switch animationMode {
        case .staggerEveryAppear:
            // For stagger mode, progress changes also trigger incremental animation
            if newValue > oldValue {
                triggerIncrementalReveal(from: oldValue, to: newValue)
            } else if newValue < oldValue {
                for i in newValue..<oldValue {
                    revealedSegments.remove(i)
                }
            }
            
        case .incrementalOnly:
            // Only animate new segments with subtle pop
            if newValue > oldValue {
                triggerIncrementalReveal(from: oldValue, to: newValue)
            } else if newValue < oldValue {
                for i in newValue..<oldValue {
                    revealedSegments.remove(i)
                }
            }
            
        case .none:
            // Instant update
            if newValue > oldValue {
                for i in oldValue..<newValue {
                    revealedSegments.insert(i)
                }
            } else {
                for i in newValue..<oldValue {
                    revealedSegments.remove(i)
                }
            }
        }
    }
    
    // MARK: - Animation Triggers
    
    /// Stagger reveal segments from 0 to `count`
    private func triggerStaggeredReveal(upTo count: Int) {
        // Small delay so SwiftUI renders empty state first
        let baseDelay = SegmentedBarAnimationConfig.renderDelay
        
        for i in 0..<count {
            let delay = baseDelay + (Double(i) * SegmentedBarAnimationConfig.staggerInterval)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(SegmentedBarAnimationConfig.staggerEasing) {
                    _ = revealedSegments.insert(i)
                }
            }
        }
    }
    
    /// Reveal new segments with subtle animation
    private func triggerIncrementalReveal(from oldCount: Int, to newCount: Int) {
        for i in oldCount..<newCount {
            let delay = Double(i - oldCount) * SegmentedBarAnimationConfig.staggerInterval
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(SegmentedBarAnimationConfig.incrementalEasing) {
                    _ = revealedSegments.insert(i)
                }
            }
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

// MARK: - Segment View (Individual Segment)

/// A single segment in the segmented bar.
/// Simple color transition — the stagger timing creates the wave effect.
private struct SegmentView: View {
    let index: Int
    let isFilled: Bool
    let isRevealed: Bool
    let filledColor: Color
    let emptyColor: Color
    let cornerRadius: CGFloat
    let width: CGFloat
    let height: CGFloat
    let animationMode: SegmentedBarAnimationMode
    
    /// The segment shows as filled only if both conditions are true:
    /// 1. It should be filled (based on progress)
    /// 2. It has been revealed (animation has triggered)
    private var showAsFilled: Bool {
        isFilled && isRevealed
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(showAsFilled ? filledColor : emptyColor)
            .frame(width: width, height: height)
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

#Preview("Animation: Initial Reveal") {
    SegmentedBarAnimationPreview()
}

#Preview("Animation: Live Step Tracking") {
    LiveStepTrackingPreview()
}

/// Preview demonstrating staggered initial reveal animation.
/// Tap to reset and replay the animation.
private struct SegmentedBarAnimationPreview: View {
    @State private var showBar = false
    @State private var progress: CGFloat = 0.75
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.xl) {
            Text("Initial Reveal Animation")
                .font(ZenoTokens.Typography.titleXSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            Text("Tap anywhere to replay")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            if showBar {
                ZenoSegmentedBar(progress: progress)
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
/// Progress increases automatically, demonstrating incremental fill animation.
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
            Text("Live Step Tracking")
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
            
            // Progress bar with incremental animation for live tracking
            ZenoSegmentedBar(
                progress: progress,
                animationMode: .incrementalOnly // Only new segments animate with subtle pop
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

