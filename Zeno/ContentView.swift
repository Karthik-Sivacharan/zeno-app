//
//  ContentView.swift
//  Zeno
//
//  Created by Karthik Sivacharan on 11/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1) // Ensure Splash stays on top during transition
                    .onAppear {
                        // Wait for Splash animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        showSplash = false
                    }
                    }
            } else {
                Group {
                    if hasCompletedOnboarding {
                        // Placeholder for HomeView
                        VStack {
                            Text("Home Screen")
                                .font(ZenoTokens.Typography.displayMedium)
                                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                            
                            Button("Reset Onboarding") {
                                hasCompletedOnboarding = false
                            }
                            .padding()
                            .background(ZenoSemanticTokens.Theme.secondary)
                            .foregroundColor(ZenoSemanticTokens.Theme.secondaryForeground)
                            .cornerRadius(ZenoSemanticTokens.Radius.md)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(ZenoSemanticTokens.Theme.background)
                        .transition(.opacity)
                    } else {
                        OnboardingFlowView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .transition(.opacity)
                    }
                }
                .zIndex(0)
            }
        }
    }
}

#Preview {
    ContentView()
}
