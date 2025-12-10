import SwiftUI

struct HealthPermissionView: View {
    @State private var viewModel = HealthPermissionViewModel()
    @State private var contentVisible = false
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            ZenoSemanticTokens.Theme.background.ignoresSafeArea()
            
            // Atmosphere
            GeometryReader { proxy in
                ZenoSemanticTokens.Gradients.swampBody
                    .overlay(
                        ZenoSemanticTokens.Gradients.deepVoid.opacity(0.8)
                    )
                    .frame(height: proxy.size.height * 0.6)
                    .mask(LinearGradient(colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom))
            }
            .ignoresSafeArea()
            
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            // Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                    
                    // Exchange Rate Visual (shown in both idle and authorized states)
                    exchangeRateVisual
                        .padding(.bottom, ZenoSemanticTokens.Space.lg)
                        .staggeredItem(index: 0, isVisible: contentVisible)
                    
                    titleView
                        .staggeredItem(index: 1, isVisible: contentVisible)
                    
                    descriptionView
                        .staggeredItem(index: 2, isVisible: contentVisible)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, ZenoSemanticTokens.Space.xl)
                
                ctaButton
                    .staggeredItem(index: 3, isVisible: contentVisible)
            }
        }
        .onAppear {
            triggerContentAnimation()
        }
    }
    
    private func triggerContentAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            contentVisible = true
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var exchangeRateVisual: some View {
        let isAuthorized = viewModel.state == .authorized
        let headerText = isAuthorized ? "Your Baseline" : "The Exchange Rate"
        let stepsText = isAuthorized ? viewModel.averageSteps.formatted() : "1,000"
        let minutesText = isAuthorized ? "\(viewModel.potentialCredits)" : "10"
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            Text(headerText)
                .font(ZenoTokens.Typography.labelLarge)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .textCase(.uppercase)
            
            HStack(alignment: .firstTextBaseline, spacing: ZenoSemanticTokens.Space.sm) {
                Text(stepsText)
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                Text("steps")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            
            Image(systemName: "arrow.down")
                .font(.title2)
                .foregroundColor(ZenoSemanticTokens.Theme.accentForeground)
                .padding(.vertical, ZenoSemanticTokens.Space.xs)
            
            HStack(alignment: .firstTextBaseline, spacing: ZenoSemanticTokens.Space.sm) {
                Text(minutesText)
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
                Text("minutes")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
            }
        }
        .animation(.easeInOut, value: viewModel.state)
    }
    
    @ViewBuilder
    private var titleView: some View {
        Text(titleText)
            .font(ZenoTokens.Typography.displayXSmall)
            .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            .fixedSize(horizontal: false, vertical: true)
            .animation(.easeInOut, value: viewModel.state)
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        Text(descriptionText)
            .font(ZenoTokens.Typography.bodyLarge)
            .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            .fixedSize(horizontal: false, vertical: true)
            .animation(.easeInOut, value: viewModel.state)
    }
    
    @ViewBuilder
    private var ctaButton: some View {
        ActionButton(ctaText, variant: .primary, isLoading: isLoading) {
            handleAction()
        }
        .padding(.horizontal, ZenoSemanticTokens.Space.lg)
        .padding(.bottom, ZenoSemanticTokens.Space.lg)
    }
    
    // MARK: - Logic & Content
    
    private var isLoading: Bool {
        if case .requesting = viewModel.state { return true }
        return false
    }
    
    private var titleText: String {
        switch viewModel.state {
        case .authorized:
            return "Baseline Established"
        default:
            return "Measure Your Steps"
        }
    }
    
    private var descriptionText: String {
        switch viewModel.state {
        case .authorized:
            return "Your average of \(viewModel.averageSteps) steps unlocks \(viewModel.potentialCredits) minutes of scrolling per day. To use more, you must walk more."
        case .error:
            return "We encountered an issue connecting to Health. Please ensure Zeno has permission in Settings."
        default:
            return "Zeno uses your daily step count to unlock apps. Give access to set your baseline."
        }
    }
    
    private var ctaText: String {
        switch viewModel.state {
        case .authorized:
            return "Continue"
        case .error:
            return "Open Settings"
        default:
            return "Connect Health"
        }
    }
    
    private func handleAction() {
        switch viewModel.state {
        case .idle:
            Task {
                await viewModel.requestAccess()
            }
        case .authorized:
            onNext()
        case .denied, .error:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .requesting:
            break
        }
    }
}

#Preview {
    HealthPermissionView(onNext: {})
}
