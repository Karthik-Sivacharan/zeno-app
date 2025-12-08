import SwiftUI
import FamilyControls

/// Settings screen for configuring blocking schedule and app selection.
struct SettingsView: View {
    @State private var schedule: BlockingSchedule
    @State private var isAppPickerPresented = false
    @State private var appSelection = FamilyActivitySelection()
    @State private var showScheduleDetail = false
    
    private let scheduleStore: BlockingScheduleStoring
    private let appsStore: ManagedAppsStoring
    
    init(
        scheduleStore: BlockingScheduleStoring = LocalBlockingScheduleStore(),
        appsStore: ManagedAppsStoring = LocalManagedAppsStore()
    ) {
        self.scheduleStore = scheduleStore
        self.appsStore = appsStore
        _schedule = State(initialValue: scheduleStore.schedule)
        _appSelection = State(initialValue: appsStore.loadConfig().selection)
    }
    
    var body: some View {
        ZStack {
            // Background fills the entire area
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xl) {
                    // Header (same as Debug view)
                    Text("Settings")
                        .font(ZenoTokens.Typography.titleMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, ZenoSemanticTokens.Space.lg)
                    
                    // MARK: - Blocked Apps Section
                    SettingsSection(title: "BLOCKED APPS") {
                        SelectionRow(
                            icon: "apps.iphone",
                            title: "Blocked Apps",
                            subtitle: "\(selectedAppCount) apps selected",
                            action: { isAppPickerPresented = true }
                        )
                        .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $appSelection)
                        .onChange(of: appSelection) { _, newSelection in
                            appsStore.updateSelection(newSelection)
                            // Re-apply blocking with new app selection
                            AppBlockingService.shared.blockApps()
                        }
                    }
                    
                    // MARK: - Schedule Section
                    SettingsSection(title: "BLOCKING SCHEDULE") {
                        SelectionRow(
                            icon: "clock",
                            title: "Schedule",
                            subtitle: scheduleSubtitle,
                            action: { showScheduleDetail = true }
                        )
                    }
                    
                    // MARK: - Account Section
                    SettingsSection(title: "ACCOUNT") {
                        SelectionRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Log out",
                            subtitle: nil,
                            action: {
                                // TODO: Implement logout
                            }
                        )
                    }
                    
                    Spacer()
                        .frame(height: ZenoSemanticTokens.Space.xxl)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .fullScreenCover(isPresented: $showScheduleDetail) {
            ScheduleDetailView(
                schedule: $schedule,
                onSave: saveSchedule
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var selectedAppCount: Int {
        appSelection.applicationTokens.count +
        appSelection.categoryTokens.count +
        appSelection.webDomainTokens.count
    }
    
    private var scheduleSubtitle: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let start = formatter.string(from: schedule.startTimeAsDate)
        let end = formatter.string(from: schedule.endTimeAsDate)
        let dayCount = schedule.activeDays.count
        let dayText = dayCount == 7 ? "Every day" : "\(dayCount) days"
        return "\(start) – \(end) • \(dayText)"
    }
    
    // MARK: - Private Methods
    
    /// Saves the schedule to local storage and registers with DeviceActivity
    private func saveSchedule() {
        scheduleStore.saveSchedule(schedule)
        
        // Register the updated schedule with DeviceActivity for OS-level enforcement
        // This immediately applies the correct blocking state based on new schedule
        AppBlockingService.shared.registerBlockingSchedule(schedule)
    }
}

// MARK: - Settings Section

/// A labeled section container for grouped settings
private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            ZenoSectionHeader(title)
            
            content
        }
    }
}

// MARK: - Schedule Detail View (Full Screen)

/// Full screen view for editing the blocking schedule
struct ScheduleDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var schedule: BlockingSchedule
    let onSave: () -> Void
    @State private var isEditingUnlocked = false
    
    var body: some View {
        ZStack {
            ZenoSemanticTokens.Theme.background
                .ignoresSafeArea()
            NoiseView(opacity: ZenoSemanticTokens.TextureIntensity.subtle)
            
            VStack(spacing: 0) {
                // Custom Header
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xl) {
                        lockedSection {
                            blockingHoursSection
                        }
                        
                        lockedSection {
                            blockingDaysSection
                        }
                        
                        Spacer()
                            .frame(height: ZenoSemanticTokens.Space.xxl)
                    }
                    .padding(.horizontal, ZenoSemanticTokens.Space.md)
                    .padding(.top, ZenoSemanticTokens.Space.lg)
                }
                
                Spacer()
                
                // Bottom friction area
                bottomAction
                    .padding(.horizontal, ZenoSemanticTokens.Space.md)
                    .padding(.bottom, ZenoSemanticTokens.Space.lg)
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text("Blocking Schedule")
                .font(ZenoTokens.Typography.titleMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: ZenoSemanticTokens.Size.iconSmall, weight: .bold))
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .frame(
                        width: ZenoSemanticTokens.Size.iconContainerMedium,
                        height: ZenoSemanticTokens.Size.iconContainerMedium
                    )
                    .background(ZenoSemanticTokens.Theme.card)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(ZenoSemanticTokens.Theme.border, lineWidth: ZenoSemanticTokens.Stroke.thin)
                    )
            }
        }
        .padding(.horizontal, ZenoSemanticTokens.Space.md)
        .padding(.vertical, ZenoSemanticTokens.Space.md)
    }
    
    // MARK: - Bottom Action
    
    private var bottomAction: some View {
        VStack(spacing: ZenoSemanticTokens.Space.md) {
            if !isEditingUnlocked {
                Callout(
                    icon: "calendar.badge.clock",
                    text: "Try sticking to your schedule for a week without changing.",
                    variant: .info
                )
            }
            
            if isEditingUnlocked {
                ActionButton("Save Schedule", variant: .primary) {
                    onSave()
                    dismiss()
                }
            } else {
                SlideToAction(label: "SLIDE TO EDIT") {
                    withAnimation(.easeInOut(duration: ZenoSemanticTokens.Motion.Duration.fast)) {
                        isEditingUnlocked = true
                    }
                }
            }
        }
    }
    
    private var blockingHoursSection: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            ZenoSectionHeader("BLOCKING HOURS")
            
            ScheduleTimeStack(
                startTime: Binding(
                    get: { schedule.startTimeAsDate },
                    set: { newDate in
                        schedule.setStartTime(from: newDate)
                    }
                ),
                endTime: Binding(
                    get: { schedule.endTimeAsDate },
                    set: { newDate in
                        schedule.setEndTime(from: newDate)
                    }
                )
            )
        }
    }
    
    private var blockingDaysSection: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            ZenoSectionHeader("BLOCKING DAYS")
            
            DayChipRow(activeDays: Binding(
                get: { schedule.activeDays },
                set: { newDays in
                    schedule.activeDays = newDays
                }
            ))
        }
    }
    
    @ViewBuilder
    private func lockedSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .disabled(!isEditingUnlocked)
            .opacity(isEditingUnlocked ? 1 : ZenoSemanticTokens.Opacity.muted)
            .animation(.easeInOut(duration: ZenoSemanticTokens.Motion.Duration.fast), value: isEditingUnlocked)
    }
}

#Preview {
    SettingsView()
}

#Preview("Schedule Detail") {
    ScheduleDetailView(
        schedule: .constant(BlockingSchedule.default),
        onSave: {}
    )
}
