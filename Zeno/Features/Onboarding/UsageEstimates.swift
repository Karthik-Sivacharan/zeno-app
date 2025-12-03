import SwiftUI

struct UsageEstimateView: View {
    let onNext: (Int) -> Void // Passes back estimated hours
    @State private var contentVisible = false
    
    private let options = [
        (text: "Under 1 hour", value: 1),
        (text: "1-3 hours", value: 2),
        (text: "3-4 hours", value: 4),
        (text: "4-5 hours", value: 5),
        (text: "5-7 hours", value: 6),
        (text: "More than 7 hours", value: 8)
    ]
    
    var body: some View {
        ZStack {
            ZenoSemanticTokens.Theme.background.ignoresSafeArea()
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            VStack(spacing: ZenoSemanticTokens.Space.lg) {
                // Question
                VStack(spacing: ZenoSemanticTokens.Space.sm) {
                    Text("Estimate Your Usage")
                        .font(ZenoTokens.Typography.labelLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .staggeredItem(index: 0, isVisible: contentVisible)
                    
                    Text("How much time do you think you spend on your phone daily?")
                        .font(ZenoTokens.Typography.titleMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .staggeredItem(index: 1, isVisible: contentVisible)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.top, ZenoSemanticTokens.Space.xl)
                
                // Options List with staggered animation
                ScrollView {
                    VStack(spacing: ZenoSemanticTokens.Space.md) {
                        ForEach(Array(options.enumerated()), id: \.element.text) { index, option in
                            Button(action: { onNext(option.value) }) {
                                Text(option.text)
                                    .font(ZenoTokens.Typography.bodyLarge)
                                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, ZenoSemanticTokens.Space.lg)
                                    .background(ZenoSemanticTokens.Theme.card)
                                    .cornerRadius(ZenoSemanticTokens.Radius.md)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                                            .stroke(ZenoSemanticTokens.Theme.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            // Start at index 2 since header takes 0 and 1
                            .staggeredItem(index: index + 2, isVisible: contentVisible)
                        }
                    }
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                }
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
}

struct UsageImpactView: View {
    let hours: Int
    let onNext: () -> Void
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            ZenoSemanticTokens.Theme.background.ignoresSafeArea()
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.standard) // Heavier noise for impact
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.lg) {
                    
                    // The Stat - dramatic staggered reveal
                    VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
                        Text("\(calculateDays()) days")
                            .font(ZenoTokens.Typography.displayXSmall)
                            .foregroundColor(ZenoSemanticTokens.Theme.destructive)
                            .staggeredItem(index: 0, isVisible: contentVisible)
                        
                        Text("a year.")
                            .font(ZenoTokens.Typography.displayXSmall)
                            .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                            .staggeredItem(index: 1, isVisible: contentVisible)
                    }
                    
                    // The Reality Check
                    Text("That is how much of your life disappears into a screen based on your estimate.")
                        .font(ZenoTokens.Typography.bodyLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                        .staggeredItem(index: 2, isVisible: contentVisible)
                    
                    Callout(
                        icon: "clock.arrow.circlepath",
                        text: "Time is the only resource you can never get back.",
                        variant: .info
                    )
                    .padding(.top, ZenoSemanticTokens.Space.sm)
                    .staggeredItem(index: 3, isVisible: contentVisible)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, ZenoSemanticTokens.Space.xl)
                
                ActionButton("Confront It", variant: .primary, action: onNext)
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
                    .staggeredItem(index: 4, isVisible: contentVisible)
            }
        }
        .onAppear {
            triggerContentAnimation()
        }
    }
    
    private func triggerContentAnimation() {
        // Slightly longer delay for dramatic effect on this impactful screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            contentVisible = true
        }
    }
    
    private func calculateDays() -> Int {
        // hours/day * 365 days / 24 hours
        return Int((Double(hours) * 365.0 / 24.0).rounded())
    }
}

#Preview {
    UsageImpactView(hours: 4, onNext: {})
}
