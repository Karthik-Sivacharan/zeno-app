import SwiftUI
import FamilyControls

struct ScreenTimePermissionView: View {
    @State private var viewModel = ScreenTimePermissionViewModel()
    @State private var contentVisible = false
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            ZenoSemanticTokens.Theme.background.ignoresSafeArea()
            
            // Atmosphere (Void + Noise)
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
                    // Title
                    Text("Confront Your Vices")
                        .font(ZenoTokens.Typography.displayXSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .fixedSize(horizontal: false, vertical: true)
                        .staggeredItem(index: 0, isVisible: contentVisible)
                    
                    // Description
                    Text("Let's take action. Zeno needs access to block distracting apps and help you break the cycle.")
                        .font(ZenoTokens.Typography.bodyLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                        .staggeredItem(index: 1, isVisible: contentVisible)
                    
                    // Security Callout (Using Component)
                    Callout(
                        icon: "lock.shield.fill",
                        text: "Your data stays on-device. Zeno cannot see your messages or content.",
                        variant: .info
                    )
                    .padding(.top, ZenoSemanticTokens.Space.sm)
                    .staggeredItem(index: 2, isVisible: contentVisible)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, ZenoSemanticTokens.Space.xl)
                
                // CTA
                ActionButton(ctaText, variant: .primary, isLoading: viewModel.isRequesting, action: handleAction)
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
                    .staggeredItem(index: 3, isVisible: contentVisible)
            }
        }
        .task {
            await viewModel.checkStatus()
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
    
    private var ctaText: String {
        switch viewModel.status {
        case .approved:
            return "Continue"
        case .denied:
            return "Open Settings"
        default:
            return "Connect Screen Time"
        }
    }
    
    private func handleAction() {
        if viewModel.status == .approved {
            onNext()
        } else if viewModel.status == .denied {
             if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } else {
            Task {
                await viewModel.requestAuthorization()
                if viewModel.status == .approved {
                    onNext()
                }
            }
        }
    }
}

@Observable
class ScreenTimePermissionViewModel {
    var status: AuthorizationStatus = .notDetermined
    var isRequesting = false
    
    private let center = AuthorizationCenter.shared
    
    func checkStatus() async {
        self.status = center.authorizationStatus
    }
    
    func requestAuthorization() async {
        isRequesting = true
        
        do {
            // Request authorization for .individual members (current user)
            try await center.requestAuthorization(for: .individual)
            self.status = center.authorizationStatus
        } catch {
            print("Screen Time Auth failed: \(error)")
            // If denied, the status update usually reflects it
            self.status = center.authorizationStatus
        }
        
        isRequesting = false
    }
}

#Preview {
    ScreenTimePermissionView(onNext: {})
}
