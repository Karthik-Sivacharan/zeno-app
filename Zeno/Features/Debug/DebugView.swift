import SwiftUI

/// Debug screen with diagnostics and development tools
struct DebugView: View {
    @State private var viewModel = HomeViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    // Accordion starts expanded
    @State private var isDebugExpanded = true
    
    var body: some View {
        ZStack {
            // Background fills the entire area
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: ZenoSemanticTokens.Space.lg) {
                    debugAccordion
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Debug Accordion
    
    private var debugAccordion: some View {
        Accordion(
            title: "Debug Panel",
            icon: "ladybug",
            isExpanded: $isDebugExpanded
        ) {
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.lg) {
                // Debug Actions Row 1
                HStack(spacing: ZenoSemanticTokens.Space.sm) {
                    Button {
                        Task {
                            await viewModel.loadData()
                        }
                    } label: {
                        HStack(spacing: ZenoSemanticTokens.Space.xs) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground)
                        .padding(.horizontal, ZenoSemanticTokens.Space.sm)
                        .padding(.vertical, ZenoSemanticTokens.Space.xs)
                        .background(ZenoSemanticTokens.Theme.muted)
                        .cornerRadius(ZenoSemanticTokens.Radius.sm)
                    }
                    
                    Button {
                        hasCompletedOnboarding = false
                    } label: {
                        HStack(spacing: ZenoSemanticTokens.Space.xs) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Onboarding")
                        }
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.destructive)
                        .padding(.horizontal, ZenoSemanticTokens.Space.sm)
                        .padding(.vertical, ZenoSemanticTokens.Space.xs)
                        .background(ZenoSemanticTokens.Theme.destructive.opacity(0.15))
                        .cornerRadius(ZenoSemanticTokens.Radius.sm)
                    }
                    
                    Spacer()
                }
                
                // Debug Actions Row 2
                HStack(spacing: ZenoSemanticTokens.Space.sm) {
                    Button {
                        viewModel.debugSpendAllCredits()
                    } label: {
                        HStack(spacing: ZenoSemanticTokens.Space.xs) {
                            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                            Text("Use All Credits")
                        }
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoTokens.ColorBase.Ember._400)
                        .padding(.horizontal, ZenoSemanticTokens.Space.sm)
                        .padding(.vertical, ZenoSemanticTokens.Space.xs)
                        .background(ZenoTokens.ColorBase.Ember._400.opacity(0.15))
                        .cornerRadius(ZenoSemanticTokens.Radius.sm)
                    }
                    .disabled(viewModel.creditsAvailable == 0)
                    .opacity(viewModel.creditsAvailable == 0 ? 0.5 : 1.0)
                    
                    Spacer()
                }
                
                // Steps Section
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
                    Label("Steps", systemImage: "figure.walk")
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    
                    debugRow(label: "Total Walked", value: viewModel.steps.formatted())
                    debugRow(label: "Available to Use", value: viewModel.stepsAvailable.formatted())
                }
                
                Divider()
                    .overlay(ZenoSemanticTokens.Theme.border)
                
                // Credits Section
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
                    Label("Credits", systemImage: "clock")
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    
                    debugRow(label: "Earned", value: "\(viewModel.creditsEarned) min")
                    debugRow(label: "Spent", value: "\(viewModel.creditsSpent) min")
                    debugRow(label: "Available", value: "\(viewModel.creditsAvailable) min", highlight: true)
                }
                
                Divider()
                    .overlay(ZenoSemanticTokens.Theme.border)
                
                // Blocked Items Section
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
                    Label("Blocked Items", systemImage: "lock.shield")
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    
                    debugRow(label: "Apps", value: "\(viewModel.blockedAppsCount)")
                    debugRow(label: "Categories", value: "\(viewModel.blockedCategoriesCount)")
                    debugRow(label: "Websites", value: "\(viewModel.blockedWebDomainsCount)")
                }
            }
        }
    }
    
    // MARK: - Debug Row Helper
    
    private func debugRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(ZenoTokens.Typography.bodySmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            Spacer()
            
            Text(value)
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(highlight ? ZenoSemanticTokens.Theme.primary : ZenoSemanticTokens.Theme.secondaryForeground)
                .monospacedDigit()
        }
    }
}

#Preview {
    DebugView()
}

