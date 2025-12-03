import SwiftUI
import FamilyControls

struct AppPickerView: View {
    let onNext: () -> Void
    
    @State private var viewModel = AppPickerViewModel()
    @State private var isPickerPresented = false
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            ZenoSemanticTokens.Theme.background.ignoresSafeArea()
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            VStack(spacing: ZenoSemanticTokens.Space.lg) {
                Spacer()
                
                // Header
                VStack(spacing: ZenoSemanticTokens.Space.md) {
                    Text("Select Your Apps")
                        .font(ZenoTokens.Typography.titleMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .staggeredItem(index: 0, isVisible: contentVisible)
                    
                    Text("Choose the apps that distract you the most. Zeno will block them until you earn access.")
                        .font(ZenoTokens.Typography.bodyLarge)
                        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .staggeredItem(index: 1, isVisible: contentVisible)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                
                // Selection Row
                SelectionRow(
                    icon: "apps.iphone",
                    title: "Blocked Apps",
                    subtitle: viewModel.selectedCount > 0 ? "\(viewModel.selectedCount) apps selected" : "Tap to select",
                    action: { isPickerPresented = true }
                )
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .familyActivityPicker(isPresented: $isPickerPresented, selection: $viewModel.selection)
                .staggeredItem(index: 2, isVisible: contentVisible)
                
                Spacer()
                
                // Footer
                ActionButton("Continue", variant: .primary, action: saveAndContinue)
                    .disabled(viewModel.selectedCount == 0)
                    .opacity(viewModel.selectedCount == 0 ? 0.5 : 1.0)
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
                    .staggeredItem(index: 3, isVisible: contentVisible)
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
    
    private func saveAndContinue() {
        viewModel.saveSelection()
        // Auto-block apps immediately after saving selection
        AppBlockingService.shared.blockApps()
        onNext()
    }
}

#Preview {
    AppPickerView(onNext: {})
}
