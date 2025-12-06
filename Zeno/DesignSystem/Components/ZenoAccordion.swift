import SwiftUI

/// A collapsible accordion component using native iOS DisclosureGroup
/// styled with Zeno design tokens.
///
/// Usage:
/// ```
/// Accordion(title: "Details", icon: "info.circle") {
///     Text("Hidden content goes here")
/// }
/// ```
struct Accordion<Content: View>: View {
    let title: String
    let icon: String?
    @Binding var isExpanded: Bool
    @ViewBuilder let content: Content
    
    /// Creates an accordion with external state control
    init(
        title: String,
        icon: String? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (tappable)
            Button {
                withAnimation(ZenoSemanticTokens.Motion.Ease.standard) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: ZenoSemanticTokens.Space.sm) {
                    // Optional leading icon
                    if let icon {
                        Image(systemName: icon)
                            .font(ZenoTokens.Typography.bodyMedium)
                            .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    }
                    
                    // Title
                    Text(title)
                        .font(ZenoTokens.Typography.labelMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground)
                    
                    Spacer()
                    
                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(ZenoSemanticTokens.Space.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    // Divider
                    Rectangle()
                        .fill(ZenoSemanticTokens.Theme.border)
                        .frame(height: ZenoSemanticTokens.Stroke.thin)
                    
                    // Content
                    content
                        .padding(ZenoSemanticTokens.Space.lg)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
        .background(ZenoSemanticTokens.Theme.secondary)
        .cornerRadius(ZenoSemanticTokens.Radius.md)
    }
}

/// Convenience initializer with internal state management
extension Accordion {
    /// Creates an accordion that manages its own expansion state
    /// - Parameters:
    ///   - title: The header title
    ///   - icon: Optional SF Symbol name for leading icon
    ///   - initiallyExpanded: Whether to start expanded (default: false)
    ///   - content: The collapsible content
    init(
        title: String,
        icon: String? = nil,
        initiallyExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        self.title = title
        self.icon = icon
        self._isExpanded = .constant(initiallyExpanded)
        self.content = content()
    }
}

/// A self-contained accordion that manages its own state
struct AccordionStateful<Content: View>: View {
    let title: String
    let icon: String?
    let initiallyExpanded: Bool
    @ViewBuilder let content: Content
    
    @State private var isExpanded: Bool
    
    init(
        title: String,
        icon: String? = nil,
        initiallyExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.initiallyExpanded = initiallyExpanded
        self.content = content()
        self._isExpanded = State(initialValue: initiallyExpanded)
    }
    
    var body: some View {
        Accordion(
            title: title,
            icon: icon,
            isExpanded: $isExpanded
        ) {
            content
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: ZenoSemanticTokens.Space.md) {
            AccordionStateful(title: "Debug Info", icon: "ladybug", initiallyExpanded: true) {
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
                    Text("Steps Walked: 3,000")
                    Text("Credits Earned: 30")
                    Text("Credits Spent: 0")
                }
                .font(ZenoTokens.Typography.bodyMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground)
            }
            
            AccordionStateful(title: "Blocked Apps", icon: "app.badge") {
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
                    Text("Blocked Apps: 5")
                    Text("Blocked Categories: 3")
                }
                .font(ZenoTokens.Typography.bodyMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground)
            }
            
            AccordionStateful(title: "Settings") {
                Text("Settings content here")
                    .font(ZenoTokens.Typography.bodyMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground)
            }
        }
        .padding()
    }
    .background(ZenoSemanticTokens.Theme.background)
}


