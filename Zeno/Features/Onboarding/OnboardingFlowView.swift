import SwiftUI

struct OnboardingFlowView: View {
    @State private var step = 0
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack {
            switch step {
            case 0:
                ExplainerView(
                    content: ExplainerContent(
                        title: "The Dopamine Trap",
                        description: "We spend hours on our phones because they give us easy, unearned dopamine. It’s not your fault, but it is a trap."
                    ),
                    onNext: {
                        withAnimation(ZenoSemanticTokens.Motion.Ease.standard) {
                            step += 1
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
            case 1:
                ExplainerView(
                    content: ExplainerContent(
                        title: "Walk to Unlock",
                        description: "Lock your distracting apps. To access them, you must walk to earn credits. Make your scrolling cost something real."
                    ),
                    onNext: {
                        withAnimation(ZenoSemanticTokens.Motion.Ease.standard) {
                            step += 1
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
            case 2:
                HealthPermissionView(
                    onNext: {
                        withAnimation(ZenoSemanticTokens.Motion.Ease.mechanical) {
                            hasCompletedOnboarding = true
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    OnboardingFlowView(hasCompletedOnboarding: .constant(false))
}

