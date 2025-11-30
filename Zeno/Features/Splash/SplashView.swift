import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Background: The "Void" (Radial Gradient for spotlight effect)
            ZenoSemanticTokens.Gradients.deepVoid
                .ignoresSafeArea()
            
            // Noise Texture: Heavy intensity to be clearly visible
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.heavy)
            
            // Content
            VStack(spacing: ZenoSemanticTokens.Space.md) {
                Text("Zeno")
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                
                Text("Earn your dopamine")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            .padding(ZenoSemanticTokens.Space.xl)
        }
    }
}

#Preview {
    SplashView()
}
