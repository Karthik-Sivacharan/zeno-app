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
    
    /// Minutes earned in this session
    private var sessionMinutesEarned: Int {
        sessionSteps / stepsPerMinute
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
            ZenoNoiseView(opacity: ZenoSemanticTokens.TextureIntensity.standard)
            
            VStack(spacing: 0) {
                // MARK: - Header
                walkHeader
                
                Spacer()
                
                // MARK: - Central Display
                centralDisplay
                
                Spacer()
                
                // MARK: - Progress Section
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
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                Image(systemName: "figure.walk")
                    .font(ZenoTokens.Typography.labelSmall)
                
                Text("Earning")
                    .font(ZenoTokens.Typography.labelMedium)
            }
            .foregroundColor(accentColor)
            .padding(.horizontal, ZenoSemanticTokens.Space.md)
            .padding(.vertical, ZenoSemanticTokens.Space.sm)
            .background(
                Capsule()
                    .fill(accentColor.opacity(0.15))
            )
            .zenoShimmer(isActive: true, duration: 2.5)
            
            // Current balance info
            Text("You have \(viewModel.creditsAvailable) min (\(viewModel.steps.formatted()) steps)")
                .font(ZenoTokens.Typography.bodySmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
        .padding(.top, ZenoSemanticTokens.Space.xl)
    }
    
    // MARK: - Central Display
    
    private var centralDisplay: some View {
        VStack(spacing: ZenoSemanticTokens.Space.lg) {
            // Session minutes earned (BIG)
            VStack(spacing: ZenoSemanticTokens.Space.xs) {
                Text("+\(sessionMinutesEarned)")
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(accentColor)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: sessionMinutesEarned)
                
                Text("minutes earned")
                    .font(ZenoTokens.Typography.labelMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            
            // Session steps (smaller)
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                Image(systemName: "shoeprints.fill")
                    .font(ZenoTokens.Typography.bodySmall)
                
                Text("\(sessionSteps.formatted()) steps this session")
                    .font(ZenoTokens.Typography.bodyMedium)
            }
            .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.2), value: sessionSteps)
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: ZenoSemanticTokens.Space.md) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.pill)
                        .fill(ZenoSemanticTokens.Theme.muted)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.pill)
                        .fill(accentColor)
                        .frame(width: geometry.size.width * progressToNextMinute)
                        .animation(.easeOut(duration: 0.3), value: progressToNextMinute)
                }
            }
            .frame(height: 8)
            
            // Progress label
            Text("\(stepsToNextMinute) steps to next minute")
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
        .padding(.horizontal, ZenoSemanticTokens.Space.lg)
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        VStack(spacing: ZenoSemanticTokens.Space.md) {
            // Total available after this session
            if sessionMinutesEarned > 0 {
                Text("Total available: \(viewModel.creditsAvailable) min")
                    .font(ZenoTokens.Typography.bodySmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .transition(.opacity)
            }
            
            ZenoButton("Done Walking", variant: .secondary) {
                isPresented = false
            }
        }
        .animation(.easeInOut, value: sessionMinutesEarned > 0)
    }
}

#Preview {
    WalkNowView(viewModel: HomeViewModel(), isPresented: .constant(true))
}

