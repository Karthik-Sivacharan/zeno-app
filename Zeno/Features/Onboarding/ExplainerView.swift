import SwiftUI

struct ExplainerContent {
    let title: String
    let description: String
}

struct ExplainerView: View {
    let content: ExplainerContent
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            // 1. Background & Atmosphere
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            
            // Top Gradient (Placeholder for assets)
            GeometryReader { proxy in
                ZenoSemanticTokens.Gradients.swampBody
                    .overlay(
                        ZenoSemanticTokens.Gradients.deepVoid
                            .opacity(0.8)
                    )
                    .frame(height: proxy.size.height * 0.6) // Top 60%
                    .mask(
                        LinearGradient(
                            colors: [.black, .black, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea()

            // Noise Texture
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            // 2. Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                    Text(content.title)
                        .font(ZenoTokens.Typography.displayXSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    
                    Text(content.description)
                        .font(ZenoTokens.Typography.bodyLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, ZenoSemanticTokens.Space.xl)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 3. CTA
                ActionButton("Next", variant: .primary, action: onNext)
                    // No horizontal padding for full width if desired, 
                    // but usually "No border radius" implies it might span full width or sit at bottom.
                    // The user said "CTA (no border radius for the priamry cta) will only be next".
                    // And "followed by the CTA in the bottom". 
                    // I'll assume full width at the bottom or just a block at bottom.
                    // Let's make it full width attached to bottom safe area? 
                    // "No border radius" strongly suggests edge-to-edge or a rectangular block.
                    // I will apply padding horizontal to 0 if it's edge to edge, or standard padding if it's a block.
                    // Let's try edge-to-edge for the "no radius" look, or just a sharp rectangle with padding.
                    // "CTA ... will only be next ... bottom".
                    // I'll add padding around it for now to be safe, but keep radius 0.
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
            }
        }
    }
}

#Preview {
    ExplainerView(
        content: ExplainerContent(
            title: "Dopamine Trap",
            description: "We spend hours on our phones because they are designed to be addictive."
        ),
        onNext: {}
    )
}

