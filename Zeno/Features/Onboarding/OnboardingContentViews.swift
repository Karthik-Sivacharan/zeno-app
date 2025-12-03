import SwiftUI
import FamilyControls

// MARK: - Health Permission Content (No Background)

struct HealthPermissionContent: View {
    @State private var viewModel = HealthPermissionViewModel()
    @State private var contentVisible = false
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                // Education Visual (Shown when Idle)
                if case .idle = viewModel.state {
                    educationVisual
                        .padding(.bottom, ZenoSemanticTokens.Space.lg)
                        .staggeredItem(index: 0, isVisible: contentVisible)
                }
                
                Text(titleText)
                    .font(ZenoTokens.Typography.displayXSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 1, isVisible: contentVisible)
                
                Text(descriptionText)
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 2, isVisible: contentVisible)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
            
            ActionButton(ctaText, variant: .primary, isLoading: isLoading, action: handleAction)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
                .staggeredItem(index: 3, isVisible: contentVisible)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
    
    @ViewBuilder
    private var educationVisual: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            Text("The Exchange Rate")
                .font(ZenoTokens.Typography.labelLarge)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .textCase(.uppercase)
            
            HStack(alignment: .firstTextBaseline, spacing: ZenoSemanticTokens.Space.sm) {
                Text("1,000")
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                Text("steps")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            
            Image(systemName: "arrow.down")
                .font(.title2)
                .foregroundColor(ZenoSemanticTokens.Theme.accentForeground)
                .padding(.vertical, ZenoSemanticTokens.Space.xs)
            
            HStack(alignment: .firstTextBaseline, spacing: ZenoSemanticTokens.Space.sm) {
                Text("10")
                    .font(ZenoTokens.Typography.displayMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
                Text("minutes")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
            }
        }
    }
    
    private var isLoading: Bool {
        if case .requesting = viewModel.state { return true }
        return false
    }
    
    private var titleText: String {
        switch viewModel.state {
        case .authorized: return "Baseline Established"
        default: return "Measure Your Steps"
        }
    }
    
    private var descriptionText: String {
        switch viewModel.state {
        case .authorized:
            return "Your average of \(viewModel.averageSteps) steps unlocks \(viewModel.potentialCredits) minutes of scrolling per day. To use more, you must walk more."
        case .error:
            return "We encountered an issue connecting to Health. Please ensure Zeno has permission in Settings."
        default:
            return "Zeno uses your daily step count to unlock apps. Give access to set your baseline."
        }
    }
    
    private var ctaText: String {
        switch viewModel.state {
        case .authorized: return "Continue"
        case .error: return "Open Settings"
        default: return "Connect Health"
        }
    }
    
    private func handleAction() {
        switch viewModel.state {
        case .idle:
            Task { await viewModel.requestAccess() }
        case .authorized:
            onNext()
        case .denied, .error:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .requesting:
            break
        }
    }
}

// MARK: - Usage Estimate Content (No Background)

struct UsageEstimateContent: View {
    let onNext: (Int) -> Void
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
        VStack(spacing: ZenoSemanticTokens.Space.lg) {
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
                        .staggeredItem(index: index + 2, isVisible: contentVisible)
                    }
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
}

// MARK: - Usage Impact Content (No Background)

struct UsageImpactContent: View {
    let hours: Int
    let onNext: () -> Void
    @State private var contentVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.lg) {
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                contentVisible = true
            }
        }
    }
    
    private func calculateDays() -> Int {
        Int((Double(hours) * 365.0 / 24.0).rounded())
    }
}

// MARK: - Screen Time Permission Content (No Background)

struct ScreenTimePermissionContent: View {
    @State private var viewModel = ScreenTimePermissionViewModel()
    @State private var contentVisible = false
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
                Text("Confront Your Vices")
                    .font(ZenoTokens.Typography.displayXSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 0, isVisible: contentVisible)
                
                Text("Let's take action. Zeno needs access to block distracting apps and help you break the cycle.")
                    .font(ZenoTokens.Typography.bodyLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredItem(index: 1, isVisible: contentVisible)
                
                Callout(
                    icon: "lock.shield.fill",
                    text: "Your data stays on-device. Zeno cannot see your messages or content.",
                    variant: .info
                )
                .padding(.top, ZenoSemanticTokens.Space.sm)
                .staggeredItem(index: 2, isVisible: contentVisible)
            }
            .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, ZenoSemanticTokens.Space.xl)
            
            ActionButton(ctaText, variant: .primary, isLoading: viewModel.isRequesting, action: handleAction)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
                .staggeredItem(index: 3, isVisible: contentVisible)
        }
        .task {
            await viewModel.checkStatus()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
    
    private var ctaText: String {
        switch viewModel.status {
        case .approved: return "Continue"
        case .denied: return "Open Settings"
        default: return "Connect Screen Time"
        }
    }
    
    private func handleAction() {
        if viewModel.status == .approved {
            onNext()
        } else if viewModel.status == .denied {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } else {
            Task {
                await viewModel.requestAuthorization()
                if viewModel.status == .approved {
                    onNext()
                }
            }
        }
    }
}

// MARK: - App Picker Content (No Background)

struct AppPickerContent: View {
    let onNext: () -> Void
    
    @State private var viewModel = AppPickerViewModel()
    @State private var isPickerPresented = false
    @State private var contentVisible = false
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.lg) {
            Spacer()
            
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
            
            ActionButton("Continue", variant: .primary, action: saveAndContinue)
                .disabled(viewModel.selectedCount == 0)
                .opacity(viewModel.selectedCount == 0 ? 0.5 : 1.0)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
                .padding(.bottom, ZenoSemanticTokens.Space.lg)
                .staggeredItem(index: 3, isVisible: contentVisible)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentVisible = true
            }
        }
    }
    
    private func saveAndContinue() {
        viewModel.saveSelection()
        AppBlockingService.shared.blockApps()
        onNext()
    }
}

