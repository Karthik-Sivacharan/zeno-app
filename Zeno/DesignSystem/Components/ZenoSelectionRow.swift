import SwiftUI

struct SelectionRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ZenoSemanticTokens.Space.md) {
                Image(systemName: icon)
                    .font(ZenoTokens.Typography.titleXSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                
                VStack(alignment: .leading, spacing: ZenoTokens.SpacingScale._0_5) {
                    Text(title)
                        .font(ZenoTokens.Typography.labelLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(ZenoTokens.Typography.bodySmall)
                            .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(ZenoTokens.Typography.labelSmall.weight(.bold))
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            .padding(ZenoSemanticTokens.Space.lg)
            .background(ZenoSemanticTokens.Theme.card)
            .cornerRadius(ZenoSemanticTokens.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                    .stroke(ZenoSemanticTokens.Theme.border, lineWidth: ZenoSemanticTokens.Stroke.thin)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SelectionRow(
            icon: "apps.iphone",
            title: "Blocked Apps",
            subtitle: "5 apps selected",
            action: {}
        )
        .padding()
    }
}

