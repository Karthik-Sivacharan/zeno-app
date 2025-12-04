import SwiftUI

/// Standard iOS-style tab bar — full width, all labels visible, color change for selection.
struct ZenoTabBar<Tab: Hashable>: View {
    @Binding var selection: Tab
    let tabs: [TabItem<Tab>]
    
    /// Accent color for selected tab
    private let selectedColor = ZenoSemanticTokens.Theme.primary
    
    /// Muted color for unselected tabs
    private let unselectedColor = ZenoSemanticTokens.Theme.mutedForeground
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, ZenoSemanticTokens.Space.sm)
        .padding(.bottom, ZenoSemanticTokens.Space.xs)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(ZenoSemanticTokens.Theme.background.opacity(0.8))
                )
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(ZenoSemanticTokens.Theme.border)
                        .frame(height: ZenoSemanticTokens.Stroke.hairline)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    @ViewBuilder
    private func tabButton(for tab: TabItem<Tab>) -> some View {
        let isSelected = selection == tab.tag
        
        Button {
            withAnimation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap)) {
                selection = tab.tag
            }
        } label: {
            VStack(spacing: ZenoSemanticTokens.Space.xs) {
                Image(systemName: isSelected ? tab.iconSelected : tab.icon)
                    .font(.system(size: 22, weight: .medium))
                
                Text(tab.label)
                    .font(ZenoTokens.Typography.labelXSmall)
            }
            .foregroundColor(isSelected ? selectedColor : unselectedColor)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Item Model

struct TabItem<Tab: Hashable>: Identifiable {
    let id = UUID()
    let tag: Tab
    let label: String
    let icon: String
    let iconSelected: String
    
    init(tag: Tab, label: String, icon: String, iconSelected: String? = nil) {
        self.tag = tag
        self.label = label
        self.icon = icon
        self.iconSelected = iconSelected ?? "\(icon).fill"
    }
}

// MARK: - App Tab Enum

/// The main navigation tabs for Zeno
enum AppTab: String, CaseIterable, Hashable {
    case home
    case debug
    case settings
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .debug: return "Debug"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .debug: return "ladybug"
        case .settings: return "gearshape"
        }
    }
    
    var iconSelected: String {
        switch self {
        case .home: return "house.fill"
        case .debug: return "ladybug.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var tabItem: TabItem<AppTab> {
        TabItem(tag: self, label: label, icon: icon, iconSelected: iconSelected)
    }
    
    static var allTabItems: [TabItem<AppTab>] {
        allCases.map { $0.tabItem }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ZenoSemanticTokens.Theme.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            ZenoTabBar(
                selection: .constant(AppTab.home),
                tabs: AppTab.allTabItems
            )
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
        }
    }
}
