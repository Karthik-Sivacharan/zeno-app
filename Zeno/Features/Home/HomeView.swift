import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.lg) {
            Text("Debug Home")
                .font(ZenoTokens.Typography.displayMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .font(ZenoTokens.Typography.bodyMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.destructive)
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                Text("Steps Walked (Total): \(viewModel.steps)")
                Text("Steps Available to Use: \(viewModel.stepsAvailable)")
                Divider()
                    .overlay(ZenoSemanticTokens.Theme.border) // Ensure divider is visible
                Text("Credits Earned (min): \(viewModel.creditsEarned)")
                Text("Credits Spent (min): \(viewModel.creditsSpent)")
                Text("Credits Available (min): \(viewModel.creditsAvailable)")
            }
            .font(ZenoTokens.Typography.bodyLarge)
            .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground) // Explicit contrast fix
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ZenoSemanticTokens.Theme.secondary)
            .cornerRadius(ZenoSemanticTokens.Radius.md)
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                Text("Blocked Apps: \(viewModel.blockedAppsCount)")
                Text("Blocked Categories: \(viewModel.blockedCategoriesCount)")
                Text("Blocked Websites: \(viewModel.blockedWebDomainsCount)")
            }
            .font(ZenoTokens.Typography.bodyLarge)
            .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground) // Explicit contrast fix
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ZenoSemanticTokens.Theme.secondary)
            .cornerRadius(ZenoSemanticTokens.Radius.md)
            
            Button("Refresh Data") {
                Task {
                    await viewModel.loadData()
                }
            }
            .padding()
            .background(ZenoSemanticTokens.Theme.primary)
            .foregroundColor(ZenoSemanticTokens.Theme.primaryForeground)
            .cornerRadius(ZenoSemanticTokens.Radius.md)
            
            Spacer()
            
            Button("Reset Onboarding") {
                hasCompletedOnboarding = false
            }
            .padding()
            .background(ZenoSemanticTokens.Theme.destructive)
            .foregroundColor(ZenoSemanticTokens.Theme.destructiveForeground)
            .cornerRadius(ZenoSemanticTokens.Radius.md)
        }
        .padding()
        .background(ZenoSemanticTokens.Theme.background)
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    HomeView()
}
