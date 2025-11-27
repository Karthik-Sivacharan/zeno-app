import SwiftUI

/// Fullscreen view displayed when the user has an active unblock session.
/// Takes over the entire screen to show the countdown timer prominently.
struct ActiveSessionView: View {
    @Bindable var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            // Background: Deep void gradient (same as splash)
            ZenoSemanticTokens.Gradients.deepVoid
                .ignoresSafeArea()
            
            // Noise texture: Standard intensity for atmosphere
            ZenoNoiseView(opacity: ZenoSemanticTokens.TextureIntensity.standard)
            
            VStack(spacing: 0) {
                // MARK: - Top Status Bar
                sessionHeader
                
                Spacer()
                
                // MARK: - Central Timer
                timerDisplay
                
                Spacer()
                
                // MARK: - Bottom Actions
                bottomActions
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
        }
    }
    
    // MARK: - Session Header
    
    /// Clay color for "unshielded" state — a warm warning tone
    private let unshieldedColor = ZenoTokens.ColorBase.Clay._400
    
    private var sessionHeader: some View {
        VStack(spacing: ZenoSemanticTokens.Space.sm) {
            // Status pill - Clay color indicates apps are exposed
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                Circle()
                    .fill(unshieldedColor)
                    .frame(width: 8, height: 8)
                
                Text("Unshielded")
                    .font(ZenoTokens.Typography.labelMedium)
                    .foregroundColor(unshieldedColor)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.md)
            .padding(.vertical, ZenoSemanticTokens.Space.sm)
            .background(
                Capsule()
                    .fill(unshieldedColor.opacity(0.15))
            )
        }
        .padding(.top, ZenoSemanticTokens.Space.xl)
    }
    
    // MARK: - Timer Display
    
    private var timerDisplay: some View {
        VStack(spacing: ZenoSemanticTokens.Space.lg) {
            // Countdown context label
            Text("Zeno will shield your apps in")
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            
            // Timer circle
            ZStack {
                // Outer ring (track)
                Circle()
                    .stroke(
                        ZenoSemanticTokens.Theme.border,
                        lineWidth: ZenoSemanticTokens.Stroke.medium
                    )
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: viewModel.sessionProgress)
                    .stroke(
                        ZenoSemanticTokens.Theme.primary,
                        style: StrokeStyle(
                            lineWidth: ZenoSemanticTokens.Stroke.thick,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.sessionProgress)
                
                // Inner fill
                Circle()
                    .fill(ZenoSemanticTokens.Theme.card.opacity(0.5))
                    .padding(ZenoSemanticTokens.Space.md)
                
                // Timer text (using title font for better accessibility)
                Text(viewModel.formattedRemainingTime)
                    .font(ZenoTokens.Typography.titleLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: viewModel.remainingSeconds)
            }
            .frame(width: 220, height: 220)
        }
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        ZenoButton("Re-shield Apps", variant: .primary) {
            viewModel.blockApps()
        }
    }
}

#Preview {
    ActiveSessionView(viewModel: HomeViewModel())
}

