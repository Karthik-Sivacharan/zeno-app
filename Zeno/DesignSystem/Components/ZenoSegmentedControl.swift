import SwiftUI

/// A compact segmented control with a visible outline and smooth selection animation.
/// Works with any enum that conforms to the required protocols.
///
/// **Usage:**
/// ```swift
/// enum DisplayMode: String, CaseIterable {
///     case steps = "Steps"
///     case time = "Time"
/// }
///
/// @State private var mode: DisplayMode = .steps
///
/// ZenoSegmentedControl(selection: $mode)
/// ```
struct ZenoSegmentedControl<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String, T.AllCases: RandomAccessCollection {
    
    /// The currently selected option
    @Binding var selection: T
    
    /// Corner radius for the control - mechanical, not pill-shaped
    private let cornerRadius = ZenoSemanticTokens.Radius.sm
    
    /// Internal padding around the segments
    private let internalPadding = ZenoTokens.SpacingScale._1 // 4pt
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(T.allCases), id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Text(option.rawValue)
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(foregroundColor(for: option))
                        .padding(.horizontal, ZenoSemanticTokens.Space.sm)
                        .padding(.vertical, ZenoSemanticTokens.Space.xs)
                        .background(backgroundColor(for: option))
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                .buttonStyle(.plain)
                .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap), value: selection)
            }
        }
        .padding(internalPadding)
        .background(controlBackground)
    }
    
    // MARK: - Segment Colors
    
    private func backgroundColor(for option: T) -> Color {
        selection == option ? ZenoSemanticTokens.Theme.primary : .clear
    }
    
    private func foregroundColor(for option: T) -> Color {
        // Active: dark text on bright primary background (high contrast)
        // Inactive: standard foreground text
        selection == option
            ? ZenoSemanticTokens.Theme.primaryForeground
            : ZenoSemanticTokens.Theme.foreground
    }
    
    // MARK: - Control Background
    
    private var controlBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius + internalPadding)
            .fill(ZenoSemanticTokens.Theme.card)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius + internalPadding)
                    .strokeBorder(
                        ZenoSemanticTokens.Theme.mutedForeground.opacity(ZenoSemanticTokens.Opacity.muted),
                        lineWidth: ZenoSemanticTokens.Stroke.thin
                    )
            )
    }
}

// MARK: - Preview

/// Example enum for previews
private enum PreviewMode: String, CaseIterable {
    case steps = "Steps"
    case time = "Time"
}

private enum PreviewTabs: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

#Preview("Segmented Control - Two Options") {
    SegmentedControlPreview()
}

#Preview("Segmented Control - Three Options") {
    ThreeOptionPreview()
}

private struct SegmentedControlPreview: View {
    @State private var selection: PreviewMode = .steps
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.xl) {
            Text("Selected: \(selection.rawValue)")
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            ZenoSegmentedControl(selection: $selection)
        }
        .padding(ZenoSemanticTokens.Space.lg)
        .background(ZenoSemanticTokens.Theme.background)
    }
}

private struct ThreeOptionPreview: View {
    @State private var selection: PreviewTabs = .all
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.xl) {
            Text("Selected: \(selection.rawValue)")
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            ZenoSegmentedControl(selection: $selection)
        }
        .padding(ZenoSemanticTokens.Space.lg)
        .background(ZenoSemanticTokens.Theme.background)
    }
}

