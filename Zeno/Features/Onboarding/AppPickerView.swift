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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: ZenoSemanticTokens.Space.lg) {
                    Spacer()
                        .frame(height: ZenoSemanticTokens.Space.xxl)
                    
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
                    
                    // Blocked Apps Selection Row
                    SelectionRow(
                        icon: "apps.iphone",
                        title: "Blocked Apps",
                        subtitle: viewModel.selectedCount > 0 ? "\(viewModel.selectedCount) apps selected" : "Tap to select",
                        action: { isPickerPresented = true }
                    )
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .familyActivityPicker(isPresented: $isPickerPresented, selection: $viewModel.selection)
                    .staggeredItem(index: 2, isVisible: contentVisible)
                    
                    // MARK: - Blocking Schedule Section
                    scheduleSection
                        .staggeredItem(index: 3, isVisible: contentVisible)
                    
                    Spacer()
                        .frame(height: ZenoSemanticTokens.Space.xxl)
                }
            }
            
            // Footer overlay
            VStack {
                Spacer()
                
                ActionButton("Continue", variant: .primary, action: saveAndContinue)
                    .disabled(viewModel.selectedCount == 0 || !viewModel.isScheduleValid)
                    .opacity((viewModel.selectedCount == 0 || !viewModel.isScheduleValid) ? 0.5 : 1.0)
                    .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
                    .background(
                        LinearGradient(
                            colors: [
                                ZenoSemanticTokens.Theme.background.opacity(0),
                                ZenoSemanticTokens.Theme.background.opacity(0.8),
                                ZenoSemanticTokens.Theme.background
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        .allowsHitTesting(false)
                    )
                    .staggeredItem(index: 6, isVisible: contentVisible)
            }
        }
        .onAppear {
            triggerContentAnimation()
        }
    }
    
    // MARK: - Schedule Section (Blocking Times + Days)
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            // Section Header
            Text("BLOCKING SCHEDULE")
                .font(ZenoTokens.Typography.labelSmall)
                .fontWeight(.semibold)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .tracking(1.5)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            
            // Time Picker Cards
            ScheduleTimeStack(
                startTime: $viewModel.scheduleStartTime,
                endTime: $viewModel.scheduleEndTime
            )
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .onChange(of: viewModel.scheduleStartTime) { _, _ in
                viewModel.validateStartTimeChange()
            }
            .onChange(of: viewModel.scheduleEndTime) { _, _ in
                viewModel.validateEndTimeChange()
            }
            
            // Days Section Header
            Text("ACTIVE ON DAYS")
                .font(ZenoTokens.Typography.labelSmall)
                .fontWeight(.semibold)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .tracking(1.5)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.top, ZenoSemanticTokens.Space.sm)
            
            // Day Chips
            DayChipRow(activeDays: $viewModel.activeDays)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
        }
    }
    
    // MARK: - Private Methods
    
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
