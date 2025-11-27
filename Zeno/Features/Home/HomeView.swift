import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @Environment(\.scenePhase) private var scenePhase
    
    // Accordion expansion states
    @State private var isDebugExpanded = false
    
    var body: some View {
        ZStack {
            // MARK: - Default Home Content
            defaultHomeContent
            
            // MARK: - Fullscreen Active Session Overlay
            if viewModel.hasActiveUnblockSession {
                ActiveSessionView(viewModel: viewModel)
                    .transition(sessionTransition)
            }
        }
        .animation(ZenoSemanticTokens.Motion.Ease.mechanical, value: viewModel.hasActiveUnblockSession)
        .task {
            await viewModel.loadData()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // App came to foreground - resync timer with real time
                viewModel.syncTimerState()
            }
        }
    }
    
    // MARK: - Session Transition
    
    /// Custom transition for the session view — slides up like a shield lowering
    private var sessionTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom)
                .combined(with: .opacity),
            removal: .move(edge: .bottom)
                .combined(with: .opacity)
        )
    }
    
    // MARK: - Default Home Content
    
    private var defaultHomeContent: some View {
        ScrollView {
            VStack(spacing: ZenoSemanticTokens.Space.lg) {
                // Error message (if any)
                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .font(ZenoTokens.Typography.bodyMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.destructive)
                        .padding()
                }
                
                // MARK: - Debug Accordion (collapsible)
                debugAccordion
            }
            .padding()
        }
        .background(ZenoSemanticTokens.Theme.background)
        .safeAreaInset(edge: .top) {
            statusHeader
        }
        .safeAreaInset(edge: .bottom) {
            floatingUnblockControls
        }
    }
    
    // MARK: - Status Header (Sticky Top)
    
    @ViewBuilder
    private var statusHeader: some View {
        if viewModel.isBlocking && viewModel.hasAppsToBlock {
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                Image(systemName: "shield.fill")
                    .font(ZenoTokens.Typography.labelSmall)
                
                Text("Zeno is shielding your apps")
                    .font(ZenoTokens.Typography.labelMedium)
            }
            .foregroundColor(ZenoSemanticTokens.Theme.primary)
            .zenoShimmer(isActive: true, duration: 2.5)
            .frame(maxWidth: .infinity)
            .padding(.vertical, ZenoSemanticTokens.Space.sm)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(ZenoSemanticTokens.Theme.background.opacity(0.8))
                    )
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(ZenoSemanticTokens.Theme.border)
                            .frame(height: ZenoSemanticTokens.Stroke.hairline)
                    }
            )
        }
    }
    
    // MARK: - Floating Unblock Controls (Sticky Bottom)
    
    private var floatingUnblockControls: some View {
        VStack(spacing: ZenoSemanticTokens.Space.md) {
            // No credits callout - show when apps are shielded but user can't afford any duration
            if !viewModel.canAffordAnyDuration && viewModel.isBlocking {
                ZenoCallout(
                    icon: "figure.walk",
                    text: "Out of time. Walk to earn more minutes!",
                    variant: .warning
                )
            }
            
            // Duration chips - only show if user can afford at least one duration AND apps are shielded
            if viewModel.canAffordAnyDuration && viewModel.isBlocking {
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.sm) {
                    Text("Select Duration")
                        .font(ZenoTokens.Typography.labelSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: ZenoSemanticTokens.Space.sm) {
                        ForEach(viewModel.availableDurations, id: \.duration.id) { item in
                            ZenoTimeChip(
                                minutes: item.duration.rawValue,
                                isSelected: viewModel.selectedDuration == item.duration,
                                isEnabled: item.isEnabled
                            ) {
                                viewModel.selectDuration(item.duration)
                            }
                        }
                    }
                }
            }
            
            // Unshield button - only relevant when apps are shielded
            // Uses muted variant (clay) to discourage frequent unshielding
            if viewModel.isBlocking {
                ZenoButton("Unshield Apps", variant: .muted, isLoading: viewModel.isUnblocking) {
                    Task {
                        await viewModel.unblockApps()
                    }
                }
                .disabled(!viewModel.canUnblock)
                .opacity(viewModel.canUnblock ? 1.0 : ZenoSemanticTokens.Opacity.disabled)
            }
            
            // Note: When apps are unblocked, the ActiveSessionView takes over fullscreen
            // This section is intentionally empty as the session UI is handled separately
            
            // No apps configured state
            if !viewModel.hasAppsToBlock {
                Text("No apps selected to shield. Complete onboarding first.")
                    .font(ZenoTokens.Typography.bodySmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, ZenoSemanticTokens.Space.lg)
        .padding(.top, ZenoSemanticTokens.Space.lg)
        .padding(.bottom, ZenoSemanticTokens.Space.md)
        .frame(maxWidth: .infinity)
        .background(
            // Frosted glass effect - extends into safe area
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(ZenoSemanticTokens.Theme.background.opacity(0.7))
                )
                .overlay(alignment: .top) {
                    // Subtle top border
                    Rectangle()
                        .fill(ZenoSemanticTokens.Theme.border)
                        .frame(height: ZenoSemanticTokens.Stroke.thin)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Debug Accordion
    
    private var debugAccordion: some View {
        ZenoAccordion(
            title: "Debug Panel",
            icon: "ladybug",
            isExpanded: $isDebugExpanded
        ) {
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.lg) {
                // Debug Actions Row
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
    HomeView()
}
