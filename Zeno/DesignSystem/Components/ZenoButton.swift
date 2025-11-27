import SwiftUI

enum ZenoButtonVariant {
    case primary
    case secondary
    case muted        // Subdued style for discouraged actions
    case ghost
}

struct ZenoButton: View {
    let title: String
    let variant: ZenoButtonVariant
    let isLoading: Bool
    let action: () -> Void
    
    init(_ title: String, variant: ZenoButtonVariant = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .opacity(isLoading ? 0 : 1)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(textColor)
                        }
                    }
                )
                .font(ZenoTokens.Typography.labelLarge)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ZenoSemanticTokens.Space.lg)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return ZenoSemanticTokens.Theme.primary
        case .secondary:
            return ZenoSemanticTokens.Theme.secondary
        case .muted:
            // Clay._600 - warm, earthy terracotta that complements green
            return ZenoTokens.ColorBase.Clay._600
        case .ghost:
            return .clear
        }
    }
    
    private var textColor: Color {
        switch variant {
        case .primary:
            return ZenoSemanticTokens.Theme.primaryForeground
        case .secondary:
            return ZenoSemanticTokens.Theme.secondaryForeground
        case .muted:
            // Light sand for good contrast on Clay background
            return ZenoTokens.ColorBase.Sand._100
        case .ghost:
            return ZenoSemanticTokens.Theme.foreground
        }
    }
    
    private var cornerRadius: CGFloat {
        switch variant {
        case .primary:
            // "no border radius for the primary cta"
            return ZenoSemanticTokens.Radius.none
        case .secondary, .muted:
            return ZenoSemanticTokens.Radius.md
        case .ghost:
            return ZenoSemanticTokens.Radius.none
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ZenoButton("Next", variant: .primary) {}
        ZenoButton("Skip", variant: .secondary) {}
        ZenoButton("Unshield Apps", variant: .muted) {}
        ZenoButton("Cancel", variant: .ghost) {}
    }
    .padding()
    .background(ZenoSemanticTokens.Theme.background)
}

