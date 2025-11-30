import SwiftUI

/// A capsule-shaped status indicator with icon and text.
/// Used in fullscreen overlays to show current state (e.g., "Earning", "Unshielded").
struct StatusPill: View {
    let icon: String
    let text: String
    let color: Color
    let showShimmer: Bool
    
    init(
        icon: String,
        text: String,
        color: Color = ZenoSemanticTokens.Theme.primary,
        showShimmer: Bool = false
    ) {
        self.icon = icon
        self.text = text
        self.color = color
        self.showShimmer = showShimmer
    }
    
    var body: some View {
        HStack(spacing: ZenoSemanticTokens.Space.xs) {
            // Icon - either SF Symbol or status dot
            if icon == "dot" {
                Circle()
                    .fill(color)
                    .frame(
                        width: ZenoSemanticTokens.Size.statusDot,
                        height: ZenoSemanticTokens.Size.statusDot
                    )
            } else {
                Image(systemName: icon)
                    .font(ZenoTokens.Typography.labelSmall)
            }
            
            Text(text)
                .font(ZenoTokens.Typography.labelMedium)
        }
        .foregroundColor(color)
        .padding(.horizontal, ZenoSemanticTokens.Space.md)
        .padding(.vertical, ZenoSemanticTokens.Space.sm)
        .background(
            Capsule()
                .fill(color.opacity(ZenoSemanticTokens.Opacity.pillBackground))
        )
        .shimmer(isActive: showShimmer, duration: ZenoSemanticTokens.Motion.Duration.breathe)
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusPill(icon: "figure.walk", text: "Earning", showShimmer: true)
        StatusPill(icon: "dot", text: "Unshielded", color: ZenoTokens.ColorBase.Clay._400)
        StatusPill(icon: "lock.shield", text: "Protected", color: ZenoSemanticTokens.Theme.primary)
    }
    .padding()
    .background(ZenoSemanticTokens.Theme.background)
}

