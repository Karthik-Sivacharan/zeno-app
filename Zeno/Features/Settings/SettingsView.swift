import SwiftUI

/// Settings screen placeholder
struct SettingsView: View {
    var body: some View {
        ZStack {
            // Background fills the entire area
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: ZenoSemanticTokens.Space.lg) {
                Spacer()
                
                // Empty state icon
                Image(systemName: "gearshape.2")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground.opacity(0.5))
                
                // Empty state text
                VStack(spacing: ZenoSemanticTokens.Space.sm) {
                    Text("Settings")
                        .font(ZenoTokens.Typography.titleSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground)
                    
                    Text("Coming soon")
                        .font(ZenoTokens.Typography.bodyMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SettingsView()
}

