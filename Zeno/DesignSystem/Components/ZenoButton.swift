import SwiftUI

enum ButtonVariant {
    case primary
    case secondary
    case muted        // Subdued style for discouraged actions
    case ghost
}

struct ActionButton: View {
    let title: String
    let icon: String?
    let variant: ButtonVariant
    let isLoading: Bool
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, variant: ButtonVariant = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ZenoSemanticTokens.Space.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(ZenoTokens.Typography.labelLarge)
                }
                Text(title)
            }
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
            .frame(height: ZenoSemanticTokens.Size.buttonHeight)
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
        // All buttons use square corners (no radius)
        ZenoSemanticTokens.Radius.none
    }
}

#Preview {
    VStack(spacing: 20) {
        ActionButton("Next", variant: .primary) {}
        ActionButton("Skip", variant: .secondary) {}
        ActionButton("Unshield Apps", variant: .muted) {}
        ActionButton("Cancel", variant: .ghost) {}
    }
    .padding()
    .background(ZenoSemanticTokens.Theme.background)
}

