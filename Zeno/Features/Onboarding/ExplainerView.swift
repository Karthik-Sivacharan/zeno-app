import SwiftUI
import SVGView

struct ExplainerContent {
    let title: String
    let description: String
    /// Optional SVG filename (without extension) to display
    let illustrationName: String?
    
    init(title: String, description: String, illustrationName: String? = nil) {
        self.title = title
        self.description = description
        self.illustrationName = illustrationName
    }
}

struct ExplainerView: View {
    let content: ExplainerContent
    let onNext: () -> Void
    
    /// Controls staggered content animation
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            // 1. Background & Atmosphere
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()

            // Noise Texture
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            // 2. Content with staggered animations
            VStack(spacing: 0) {
                // Illustration Area
                if let illustrationName = content.illustrationName,
                   let url = Bundle.main.url(forResource: illustrationName, withExtension: "svg") {
                    SVGView(contentsOf: url)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.42)
                        .staggeredItem(index: 0, isVisible: contentVisible)
                } else {
                    // Placeholder space when no illustration
                    Spacer()
                        .frame(height: ZenoSemanticTokens.Space.xxl)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                    // Title - appears second
                    Text(content.title)
                        .font(ZenoTokens.Typography.displayXSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .fixedSize(horizontal: false, vertical: true)
                        .staggeredItem(index: 1, isVisible: contentVisible)
                    
                    // Description - appears third
                    Text(content.description)
                        .font(ZenoTokens.Typography.bodyLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, ZenoSemanticTokens.Space.xl)
                        .staggeredItem(index: 2, isVisible: contentVisible)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 3. CTA - appears last with slight delay
                ActionButton("Next", variant: .primary, action: onNext)
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
                    .staggeredItem(index: 3, isVisible: contentVisible)
            }
        }
        .onAppear {
            // Trigger staggered animation when view appears
            triggerContentAnimation()
        }
    }
    
    private func triggerContentAnimation() {
        // Small delay before starting animations for smoother page transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            contentVisible = true
        }
    }
}

#Preview {
    ExplainerView(
        content: ExplainerContent(
            title: "The Dopamine Trap",
            description: "We spend hours on our phones because they are designed to be addictive.",
            illustrationName: "zen-svg-1"
        ),
        onNext: {}
    )
}
