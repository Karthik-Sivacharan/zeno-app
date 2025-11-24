import SwiftUI

struct OnboardingFlowView: View {
    @State private var step = 0
    @Binding var hasCompletedOnboarding: Bool
    @State private var estimatedHours = 0 // Store the estimate to pass to Impact view
    
    var body: some View {
        ZStack {
            switch step {
            case 0:
                ExplainerView(
                    content: ExplainerContent(
                        title: "The Dopamine Trap",
                        description: "We spend hours on our phones because they give us easy, unearned dopamine. It’s not your fault, but it is a trap."
                    ),
                    onNext: advanceStep
                )
                .transition(transitionFor(step: 0))
                
            case 1:
                ExplainerView(
                    content: ExplainerContent(
                        title: "Walk to Unlock",
                        description: "Lock your distracting apps. To access them, you must walk to earn credits. Make your scrolling cost something real."
                    ),
                    onNext: advanceStep
                )
                .transition(transitionFor(step: 1))
            
            case 2:
                HealthPermissionView(
                    onNext: advanceStep
                )
                .transition(transitionFor(step: 2))
                
            case 3:
                UsageEstimateView(
                    onNext: { hours in
                        estimatedHours = hours
                        advanceStep()
                    }
                )
                .transition(transitionFor(step: 3))
                
            case 4:
                UsageImpactView(
                    hours: estimatedHours,
                    onNext: advanceStep
                )
                .transition(transitionFor(step: 4))
            
            case 5:
                ScreenTimePermissionView(
                    onNext: advanceStep
                )
                .transition(transitionFor(step: 5))
                
            case 6:
                AppPickerView(
                    onNext: advanceStep
                )
                .transition(transitionFor(step: 6))
                
            case 7:
                // Final step - transition to Home
                Color.clear.onAppear {
                     withAnimation(ZenoSemanticTokens.Motion.Ease.mechanical) {
                        hasCompletedOnboarding = true
                    }
                }
                
            default:
                EmptyView()
            }
        }
        .animation(ZenoSemanticTokens.Motion.Ease.standard, value: step)
    }
    
    private func advanceStep() {
        withAnimation(ZenoSemanticTokens.Motion.Ease.standard) {
            step += 1
        }
    }
    
    private func transitionFor(step: Int) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

#Preview {
    OnboardingFlowView(hasCompletedOnboarding: .constant(false))
}
