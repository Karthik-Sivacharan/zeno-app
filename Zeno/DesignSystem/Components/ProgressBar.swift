import SwiftUI

/// A horizontal progress bar with animated fill.
/// Used to show progress toward goals (e.g., steps to next minute).
struct ProgressBar: View {
    let progress: CGFloat
    let color: Color
    let trackColor: Color
    let height: CGFloat
    
    init(
        progress: CGFloat,
        color: Color = ZenoSemanticTokens.Theme.primary,
        trackColor: Color = ZenoSemanticTokens.Theme.muted,
        height: CGFloat = ZenoSemanticTokens.Size.progressBarHeight
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp 0-1
        self.color = color
        self.trackColor = trackColor
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.pill)
                    .fill(trackColor)
                
                // Fill
                RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.pill)
                    .fill(color)
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.fast), value: progress)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.0)
        ProgressBar(progress: 0.25)
        ProgressBar(progress: 0.5, color: ZenoTokens.ColorBase.Ember._400)
        ProgressBar(progress: 0.75)
        ProgressBar(progress: 1.0)
    }
    .padding()
    .background(ZenoSemanticTokens.Theme.background)
}


