import SwiftUI

/// A selectable chip for displaying time duration options.
/// Used in the blocking flow for users to select how long to unblock apps.
///
/// The chip has three states:
/// - **Default**: Subtle background with muted border
/// - **Selected**: Primary accent with visible border
/// - **Disabled**: Reduced opacity, non-interactive
struct TimeChip: View {
    let minutes: Int
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    /// Corner radius matches the mechanical Zeno aesthetic (not pill-shaped)
    private let cornerRadius = ZenoSemanticTokens.Radius.md
    
    var body: some View {
        Button(action: action) {
            Text("\(minutes) min")
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(foregroundColor)
                .fixedSize()  // Prevents text from wrapping on small screens
                .padding(.horizontal, ZenoSemanticTokens.Space.md)
                .padding(.vertical, ZenoSemanticTokens.Space.sm)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : ZenoSemanticTokens.Opacity.disabled)
        // Snappy animation for immediate feedback on selection
        .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap), value: isSelected)
    }
    
    // MARK: - Computed Styles
    
    private var backgroundColor: Color {
        if isSelected {
            return ZenoSemanticTokens.Theme.primary.opacity(0.15)
        }
        return ZenoSemanticTokens.Theme.secondary
    }
    
    private var foregroundColor: Color {
        if !isEnabled {
            return ZenoSemanticTokens.Theme.mutedForeground
        }
        if isSelected {
            return ZenoSemanticTokens.Theme.primary
        }
        return ZenoSemanticTokens.Theme.secondaryForeground
    }
    
    private var borderColor: Color {
        if isSelected {
            return ZenoSemanticTokens.Theme.primary
        }
        return ZenoSemanticTokens.Theme.border
    }
    
    private var borderWidth: CGFloat {
        isSelected ? ZenoSemanticTokens.Stroke.medium : ZenoSemanticTokens.Stroke.thin
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: ZenoSemanticTokens.Space.sm) {
        TimeChip(minutes: 2, isSelected: false, isEnabled: true) {}
        TimeChip(minutes: 5, isSelected: true, isEnabled: true) {}
        TimeChip(minutes: 10, isSelected: false, isEnabled: true) {}
        TimeChip(minutes: 15, isSelected: false, isEnabled: false) {}
    }
    .padding()
    .background(ZenoSemanticTokens.Theme.background)
}

