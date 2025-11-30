import SwiftUI

struct UsageEstimateView: View {
    let onNext: (Int) -> Void // Passes back estimated hours
    
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
                    
                    Text("How much time do you think you spend on your phone daily?")
                        .font(ZenoTokens.Typography.titleMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.top, ZenoSemanticTokens.Space.xl)
                
                // Options List
                ScrollView {
                    VStack(spacing: ZenoSemanticTokens.Space.md) {
                        ForEach(options, id: \.text) { option in
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
                        }
                    }
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                }
            }
        }
    }
}

struct UsageImpactView: View {
    let hours: Int
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            ZenoSemanticTokens.Theme.background.ignoresSafeArea()
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.standard) // Heavier noise for impact
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.lg) {
                    
                    // The Stat
                    VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
                        Text("\(calculateDays()) days")
                            .font(ZenoTokens.Typography.displayXSmall)
                            .foregroundColor(ZenoSemanticTokens.Theme.destructive) // Red color for impact
                        
                        Text("a year.")
                            .font(ZenoTokens.Typography.displayXSmall)
                            .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    }
                    
                    // The Reality Check
                    Text("That is how much of your life disappears into a screen based on your estimate.")
                        .font(ZenoTokens.Typography.bodyLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Callout(
                        icon: "clock.arrow.circlepath",
                        text: "Time is the only resource you can never get back.",
                        variant: .info
                    )
                    .padding(.top, ZenoSemanticTokens.Space.sm)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, ZenoSemanticTokens.Space.xl) // Spacing from CTA
                
                // No spacer here to keep it bottom-heavy
                
                ActionButton("Confront It", variant: .primary, action: onNext)
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
            }
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
