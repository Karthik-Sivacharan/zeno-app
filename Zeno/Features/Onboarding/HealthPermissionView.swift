import SwiftUI

struct HealthPermissionView: View {
    @State private var viewModel = HealthPermissionViewModel()
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
            
            ZenoNoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            // Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                    
                    // Education Visual (Shown when Idle)
                    if case .idle = viewModel.state {
                        educationVisual
                            .padding(.bottom, ZenoSemanticTokens.Space.lg)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    titleView
                    descriptionView
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, ZenoSemanticTokens.Space.xl)
                
                ctaButton
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var educationVisual: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            Text("The Exchange Rate")
                .font(ZenoTokens.Typography.labelLarge)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .textCase(.uppercase)
            
            HStack(alignment: .firstTextBaseline, spacing: ZenoSemanticTokens.Space.sm) {
                Text("1,000")
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
                Text("10")
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
                Text("minutes")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
            }
        }
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
        ZenoButton(ctaText, variant: .primary, isLoading: isLoading) {
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
