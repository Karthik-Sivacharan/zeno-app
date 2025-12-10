import SwiftUI

/// Icon size variants following the design system
enum ZenoIconSize {
    case small   // 14pt icon in 14pt container
    case medium  // 16pt icon in 16pt container
    case large   // 22pt icon in 22pt container
    
    /// The font size for the SF Symbol
    var fontSize: CGFloat {
        switch self {
        case .small: return ZenoSemanticTokens.Size.iconSmall
        case .medium: return ZenoSemanticTokens.Size.iconMedium
        case .large: return ZenoSemanticTokens.Size.iconLarge
        }
    }
    
    /// The fixed container size (prevents layout shift between different SF Symbols)
    var containerSize: CGFloat {
        switch self {
        case .small: return ZenoSemanticTokens.Size.iconSmall
        case .medium: return ZenoSemanticTokens.Size.iconMedium
        case .large: return ZenoSemanticTokens.Size.iconLarge
        }
    }
}

/// A standardized icon component that ensures consistent sizing across different SF Symbols.
///
/// SF Symbols have varying optical sizes and aspect ratios. This component wraps them
/// in a fixed-size container to prevent layout shifts when icons change (e.g., in toggles).
///
/// **Usage:**
/// ```swift
/// ZenoIcon("figure.walk", size: .medium, color: .primary)
/// ZenoIcon("hourglass", size: .medium, color: .primary)
/// ```
///
/// **When to use:**
/// - Tab bars, toolbars
/// - Toggles where icons change
/// - Any place where consistent icon sizing matters
struct ZenoIcon: View {
    let systemName: String
    let size: ZenoIconSize
    let color: Color
    
    init(
        _ systemName: String,
        size: ZenoIconSize = .medium,
        color: Color = ZenoSemanticTokens.Theme.foreground
    ) {
        self.systemName = systemName
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size.fontSize))
            .foregroundColor(color)
            .frame(width: size.containerSize, height: size.containerSize)
    }
}

// MARK: - Preview

#Preview("ZenoIcon Sizes") {
    VStack(spacing: ZenoSemanticTokens.Space.xl) {
        // Small icons
        HStack(spacing: ZenoSemanticTokens.Space.md) {
            Text("Small (14pt)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            Spacer()
            ZenoIcon("figure.walk", size: .small, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("hourglass", size: .small, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("clock", size: .small, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("lock.open", size: .small, color: ZenoSemanticTokens.Theme.primary)
        }
        
        // Medium icons
        HStack(spacing: ZenoSemanticTokens.Space.md) {
            Text("Medium (16pt)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            Spacer()
            ZenoIcon("figure.walk", size: .medium, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("hourglass", size: .medium, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("clock", size: .medium, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("lock.open", size: .medium, color: ZenoSemanticTokens.Theme.primary)
        }
        
        // Large icons
        HStack(spacing: ZenoSemanticTokens.Space.md) {
            Text("Large (22pt)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            Spacer()
            ZenoIcon("figure.walk", size: .large, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("hourglass", size: .large, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("clock", size: .large, color: ZenoSemanticTokens.Theme.primary)
            ZenoIcon("lock.open", size: .large, color: ZenoSemanticTokens.Theme.primary)
        }
        
        Divider()
        
        // Demo: Icons changing in a toggle (no layout shift)
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
            Text("Toggle Demo (no layout shift)")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                ZenoIcon("figure.walk", size: .medium, color: ZenoSemanticTokens.Theme.primary)
                Text("4,500")
                    .font(ZenoTokens.Typography.monoMedium)
                Text("left to use")
                    .font(ZenoTokens.Typography.labelSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                ZenoIcon("hourglass", size: .medium, color: ZenoSemanticTokens.Theme.primary)
                Text("45")
                    .font(ZenoTokens.Typography.monoMedium)
                Text("left to use")
                    .font(ZenoTokens.Typography.labelSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
        }
    }
    .padding(ZenoSemanticTokens.Space.lg)
    .background(ZenoSemanticTokens.Theme.background)
}

