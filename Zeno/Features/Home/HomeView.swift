import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    // Tab selection
    @State private var selectedTab: AppTab = .home
    
    // Walk Now sheet state
    @State private var isShowingWalkNow = false
    
    var body: some View {
        ZStack {
            // MARK: - Stable Background (never animates)
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            
            // MARK: - Tab Content (animated)
            ZStack {
                if selectedTab == .home {
                    homeTabContent
                        .transition(TabTransition.lift)
                }
                
                if selectedTab == .debug {
                    debugTabContent
                        .transition(TabTransition.lift)
                }
                
                if selectedTab == .settings {
                    settingsTabContent
                        .transition(TabTransition.lift)
                }
            }
            .animation(.smooth(duration: ZenoSemanticTokens.Motion.Duration.fast), value: selectedTab)
            
            // MARK: - Fullscreen Active Session Overlay (only on Home tab)
            if selectedTab == .home && viewModel.hasActiveUnblockSession {
                ActiveSessionView(viewModel: viewModel)
                    .transition(fullscreenTransition)
            }
            
            // MARK: - Fullscreen Walk Now Overlay (only on Home tab)
            if selectedTab == .home && isShowingWalkNow {
                WalkNowView(viewModel: viewModel, isPresented: $isShowingWalkNow)
                    .transition(fullscreenTransition)
            }
        }
        // MARK: - Fixed Bottom Area (hidden when fullscreen overlays are active)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .animation(ZenoSemanticTokens.Motion.Ease.mechanical, value: viewModel.hasActiveUnblockSession)
        .animation(ZenoSemanticTokens.Motion.Ease.mechanical, value: isShowingWalkNow)
        .task {
            await viewModel.loadData()
            // Start real-time step observation when view appears
            viewModel.startObservingSteps()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                // App came to foreground - resync timer and start step observation
                viewModel.syncTimerState()
                viewModel.startObservingSteps()
            case .background, .inactive:
                // App going to background - stop step observation to save battery
                viewModel.stopObservingSteps()
            @unknown default:
                break
            }
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            // Refresh data when returning to Home tab (e.g., after using Debug tools)
            if newTab == .home {
                Task {
                    await viewModel.loadData()
                }
            }
        }
        .onDisappear {
            // Clean up observation when view disappears
            viewModel.stopObservingSteps()
        }
    }
    
    // MARK: - Debug Tab Content
    
    private var debugTabContent: some View {
        DebugView()
    }
    
    // MARK: - Settings Tab Content
    
    private var settingsTabContent: some View {
        SettingsView()
    }
    
    // MARK: - Fullscreen Transition
    
    /// Custom transition for fullscreen overlays — slides up smoothly
    private var fullscreenTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom)
                .combined(with: .opacity),
            removal: .move(edge: .bottom)
                .combined(with: .opacity)
        )
    }
    
    // MARK: - Home Tab Content
    
    private var homeTabContent: some View {
        // Note: Background is stable at parent level (never animates during tab transitions)
        // Tab bar + floating controls are at parent level (stay fixed during transitions)
        ScrollView(showsIndicators: false) {
            VStack(spacing: ZenoSemanticTokens.Space.xl) {
                // Error message (if any) - displayed as a friendly callout
                if let error = viewModel.errorMessage {
                    Callout(
                        icon: "exclamationmark.triangle",
                        text: error,
                        variant: .warning
                    )
                }
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .top) {
            statusHeader
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
            .shimmer(isActive: true, duration: 2.5)
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
            // No credits section - show when apps are shielded but user can't afford any duration
            if !viewModel.canAffordAnyDuration && viewModel.isBlocking {
                VStack(spacing: ZenoSemanticTokens.Space.md) {
                    Callout(
                        icon: "exclamationmark.triangle",
                        text: "Out of time. Walk to earn more minutes!",
                        variant: .warning
                    )
                    
                    // Walk Now CTA - bright green to encourage action
                    ActionButton("Walk Now", icon: "figure.walk", variant: .primary) {
                        isShowingWalkNow = true
                    }
                }
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
                            TimeChip(
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
            
            // Unshield button - only show when apps are shielded AND user can afford at least one duration
            // Hidden when user has 0 credits (Walk Now takes over)
            if viewModel.isBlocking && viewModel.canAffordAnyDuration {
                ActionButton("Unshield Apps", variant: .muted, isLoading: viewModel.isUnblocking) {
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
        .padding(.vertical, ZenoSemanticTokens.Space.lg)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(ZenoSemanticTokens.Theme.card.opacity(0.95))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(ZenoSemanticTokens.Theme.border)
                        .frame(height: ZenoSemanticTokens.Stroke.hairline)
                }
        )
    }
    
    // MARK: - Bottom Bar (Tab Bar + Floating Controls)
    
    /// Returns the bottom bar (tab bar + floating controls) or nothing when fullscreen overlays are active
    @ViewBuilder
    private var bottomBar: some View {
        // Hide entire bottom area when fullscreen overlays (WalkNow, ActiveSession) are showing
        if isShowingWalkNow || viewModel.hasActiveUnblockSession {
            // Return nothing — fullscreen overlays cover the tab bar
            EmptyView()
        } else {
            VStack(spacing: 0) {
                // Floating controls only on Home tab
                if selectedTab == .home {
                    floatingUnblockControls
                }
                tabBar
            }
            // Prevent tab content animations from affecting the bottom bar layout
            .animation(nil, value: selectedTab)
        }
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        ZenoTabBar(selection: $selectedTab, tabs: AppTab.allTabItems)
    }
    
}

#Preview {
    HomeView()
}


