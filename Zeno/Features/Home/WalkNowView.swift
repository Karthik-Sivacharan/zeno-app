import SwiftUI

/// Fullscreen overlay displayed when user has insufficient credits.
/// Shows real-time step tracking with focus on earning minutes.
struct WalkNowView: View {
    @Bindable var viewModel: HomeViewModel
    @Binding var isPresented: Bool
    
    /// Steps recorded when this view was opened (for session tracking)
    @State private var sessionStartSteps: Int = 0
    
    /// Whether we've captured the starting steps
    @State private var hasRecordedStart: Bool = false
    
    // MARK: - Computed Properties
    
    /// Steps walked in this session
    private var sessionSteps: Int {
        max(0, viewModel.steps - sessionStartSteps)
    }
    
    /// Progress toward the next minute (0.0 to 1.0)
    private var progressToNextMinute: CGFloat {
        let remainder = sessionSteps % stepsPerMinute
        return CGFloat(remainder) / CGFloat(stepsPerMinute)
    }
    
    /// Steps remaining until the next minute is earned
    private var stepsToNextMinute: Int {
        stepsPerMinute - (sessionSteps % stepsPerMinute)
    }
    
    /// Steps required for 1 minute of credit
    private let stepsPerMinute: Int = 100
    
    /// The accent color for this view — bright acid green
    private let accentColor = ZenoSemanticTokens.Theme.primary
    
    
    var body: some View {
        ZStack {
            // Background: Deep void gradient
            ZenoSemanticTokens.Gradients.deepVoid
                .ignoresSafeArea()
            
            // Noise texture
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.standard)
            
            VStack(spacing: 0) {
                // MARK: - Header
                walkHeader
                
                Spacer()
                
                // MARK: - Central Display
                stepRingDisplay
                
                Spacer()
                
                // MARK: - Progress to Next Minute
                progressSection
                
                Spacer()
                    .frame(height: ZenoSemanticTokens.Space.xl)
                
                // MARK: - Bottom Actions
                bottomActions
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
        }
        .onAppear {
            // Record starting steps when view appears
            if !hasRecordedStart {
                sessionStartSteps = viewModel.steps
                hasRecordedStart = true
            }
        }
    }
    
    // MARK: - Header
    
    private var walkHeader: some View {
        VStack(spacing: ZenoSemanticTokens.Space.sm) {
            // Status pill
            StatusPill(
                icon: "figure.walk",
                text: "Earning",
                color: accentColor,
                showShimmer: false
            )
            
            // Current balance (subtle)
            Text("Balance: \(viewModel.creditsAvailable) min")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
        .padding(.top, ZenoSemanticTokens.Space.xl)
    }
    
    // MARK: - Step Display
    
    private var stepRingDisplay: some View {
        VStack(spacing: ZenoTokens.SpacingScale._1) {
            Text("\(sessionSteps)")
                .font(ZenoTokens.Typography.monoDisplayXLarge)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: ZenoSemanticTokens.Motion.Duration.snap), value: sessionSteps)
            
            Text("steps")
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: ZenoSemanticTokens.Space.sm) {
            // Progress bar to next minute - using new component
            ProgressBar(progress: progressToNextMinute, color: accentColor)
            
            // Progress label - shows steps toward next minute
            Text("\(stepsToNextMinute) more steps for +1 min")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
        .padding(.horizontal, ZenoSemanticTokens.Space.xl)
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        ActionButton("Done Walking", variant: .secondary) {
            isPresented = false
        }
    }
}

#Preview {
    WalkNowView(viewModel: HomeViewModel(), isPresented: .constant(true))
}
