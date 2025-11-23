import SwiftUI

struct HealthPermissionView: View {
    @State private var viewModel = HealthPermissionViewModel()
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            
            // Atmosphere
            GeometryReader { proxy in
                ZenoSemanticTokens.Gradients.swampBody
                    .overlay(
                        ZenoSemanticTokens.Gradients.deepVoid
                            .opacity(0.8)
                    )
                    .frame(height: proxy.size.height * 0.6)
                    .mask(
                        LinearGradient(
                            colors: [.black, .black, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea()
            
            ZenoNoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            // Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
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
            return "Analysis Complete"
        default:
            return "Measure Your Steps"
        }
    }
    
    private var descriptionText: String {
        switch viewModel.state {
        case .authorized:
            return "You average \(viewModel.averageSteps) steps a day. That earns you \(viewModel.potentialCredits) minutes of screen time daily!"
        case .error:
            return "We encountered an issue connecting to Health. Please ensure Zeno has permission in Settings."
        default:
            return "Zeno uses your daily step count to unlock apps. Give access to see how many minutes you've already earned."
        }
    }
    
    private var ctaText: String {
        switch viewModel.state {
        case .authorized:
            return "Start Moving"
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
            // For MVP, just try again or move on? 
            // Usually we'd open settings.
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .requesting:
            break
        }
    }
}

extension HealthPermissionViewModel.PermissionState: Equatable {
    static func == (lhs: HealthPermissionViewModel.PermissionState, rhs: HealthPermissionViewModel.PermissionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.requesting, .requesting), (.authorized, .authorized), (.denied, .denied):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

#Preview {
    HealthPermissionView(onNext: {})
}

