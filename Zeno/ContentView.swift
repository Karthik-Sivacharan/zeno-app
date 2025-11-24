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
                    .task {
                        // Wait for Splash animation
                        try? await Task.sleep(for: .seconds(2.5))
                        withAnimation {
                            showSplash = false
                        }
                    }
            } else {
                Group {
                    if hasCompletedOnboarding {
                        HomeView()
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
