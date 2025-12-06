import SwiftUI

/// A sleek progress bar with tick marks, inspired by GoClub's gauge-style design.
/// Shows progress with an acid gradient fill and subtle ruler-like tick marks.
struct ZenoGaugeBar: View {
    /// Progress value between 0 and 1
    let progress: CGFloat
    
    /// Number of tick marks to display
    let tickCount: Int
    
    /// Height of the bar
    let height: CGFloat
    
    /// Whether to show the gradient fill (vs solid color)
    let useGradient: Bool
    
    init(
        progress: CGFloat,
        tickCount: Int = 20,
        height: CGFloat = ZenoTokens.SpacingScale._3, // 12pt
        useGradient: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.tickCount = tickCount
        self.height = height
        self.useGradient = useGradient
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // MARK: - Track (Background) - More visible empty state
                Capsule()
                    .fill(ZenoTokens.ColorBase.Moss._700)
                
                // MARK: - Tick Marks Overlay
                tickMarksView(in: geometry)
                
                // MARK: - Filled Portion
                if progress > 0 {
                    Capsule()
                        .fill(fillStyle)
                        .frame(width: max(geometry.size.width * progress, height)) // Min width = height for rounded cap
                        .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.fast), value: progress)
                }
            }
        }
        .frame(height: height)
    }
    
    // MARK: - Fill Style
    
    private var fillStyle: AnyShapeStyle {
        if useGradient {
            AnyShapeStyle(ZenoSemanticTokens.Gradients.acidFlow)
        } else {
            AnyShapeStyle(ZenoSemanticTokens.Theme.primary)
        }
    }
    
    // MARK: - Tick Marks
    
    private func tickMarksView(in geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<tickCount, id: \.self) { index in
                Spacer()
                
                if index < tickCount - 1 {
                    // Tick mark line
                    Rectangle()
                        .fill(tickColor(for: index, in: geometry))
                        .frame(width: ZenoSemanticTokens.Stroke.hairline, height: tickHeight(for: index))
                }
            }
            Spacer()
        }
        .padding(.horizontal, height / 2) // Inset from capsule edges
    }
    
    /// Determines tick color based on whether it's in the filled portion
    private func tickColor(for index: Int, in geometry: GeometryProxy) -> Color {
        let tickPosition = CGFloat(index + 1) / CGFloat(tickCount)
        
        if tickPosition <= progress {
            // Tick is within filled area - use contrasting color
            return ZenoTokens.ColorBase.Olive._950.opacity(0.4)
        } else {
            // Tick is in unfilled area - visible against Moss._700 track
            return ZenoTokens.ColorBase.Moss._500.opacity(0.5)
        }
    }
    
    /// Alternating tick heights for visual rhythm
    private func tickHeight(for index: Int) -> CGFloat {
        // Every 5th tick is taller (like a ruler)
        if (index + 1) % 5 == 0 {
            return height * 0.7
        }
        return height * 0.4
    }
}

// MARK: - Preview

#Preview("Gauge Bar States") {
    VStack(spacing: ZenoSemanticTokens.Space.xl) {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("0%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 0)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("25%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 0.25)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("50%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 0.50)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("75%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 0.75)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("100%")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 1.0)
        }
    }
    .padding(ZenoSemanticTokens.Space.lg)
    .background(ZenoSemanticTokens.Theme.background)
}

#Preview("Gauge Bar Sizes") {
    VStack(spacing: ZenoSemanticTokens.Space.xl) {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Small (8pt)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 0.6, height: ZenoTokens.SpacingScale._2)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Default (12pt)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 0.6)
        }
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            Text("Large (16pt)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            ZenoGaugeBar(progress: 0.6, height: ZenoTokens.SpacingScale._4)
        }
    }
    .padding(ZenoSemanticTokens.Space.lg)
    .background(ZenoSemanticTokens.Theme.background)
}
