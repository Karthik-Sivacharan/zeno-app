import SwiftUI
import FamilyControls

/// Settings screen for configuring blocking schedule and app selection.
struct SettingsView: View {
    @State private var schedule: BlockingSchedule
    @State private var isAppPickerPresented = false
    @State private var appSelection = FamilyActivitySelection()
    
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
                VStack(spacing: ZenoSemanticTokens.Space.xl) {
                    // Header
                    Text("Settings")
                        .font(ZenoTokens.Typography.titleMedium)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, ZenoSemanticTokens.Space.lg)
                    
                    // MARK: - Blocked Apps Section
                    blockedAppsSection
                    
                    // MARK: - Schedule Section
                    scheduleSection
                    
                    Spacer()
                        .frame(height: ZenoSemanticTokens.Space.xxl)
                }
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            }
        }
    }
    
    // MARK: - Blocked Apps Section
    
    private var blockedAppsSection: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            Text("BLOCKED APPS")
                .font(ZenoTokens.Typography.labelSmall)
                .fontWeight(.semibold)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .tracking(1.5)
            
            SelectionRow(
                icon: "apps.iphone",
                title: "Blocked Apps",
                subtitle: "\(selectedAppCount) apps selected",
                action: { isAppPickerPresented = true }
            )
            .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $appSelection)
            .onChange(of: appSelection) { _, newSelection in
                appsStore.updateSelection(newSelection)
                // Re-apply blocking with new selection
                AppBlockingService.shared.blockApps()
            }
        }
    }
    
    // MARK: - Schedule Section
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.md) {
            Text("BLOCKING SCHEDULE")
                .font(ZenoTokens.Typography.labelSmall)
                .fontWeight(.semibold)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .tracking(1.5)
            
            // Time Picker Cards
            ScheduleTimeStack(
                startTime: Binding(
                    get: { schedule.startTimeAsDate },
                    set: { newDate in
                        schedule.setStartTime(from: newDate)
                        saveSchedule()
                    }
                ),
                endTime: Binding(
                    get: { schedule.endTimeAsDate },
                    set: { newDate in
                        schedule.setEndTime(from: newDate)
                        saveSchedule()
                    }
                )
            )
            
            // Days Section
            Text("ACTIVE ON DAYS")
                .font(ZenoTokens.Typography.labelSmall)
                .fontWeight(.semibold)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                .tracking(1.5)
                .padding(.top, ZenoSemanticTokens.Space.sm)
            
            DayChipRow(activeDays: Binding(
                get: { schedule.activeDays },
                set: { newDays in
                    schedule.activeDays = newDays
                    saveSchedule()
                }
            ))
        }
    }
    
    // MARK: - Computed Properties
    
    private var selectedAppCount: Int {
        appSelection.applicationTokens.count +
        appSelection.categoryTokens.count +
        appSelection.webDomainTokens.count
    }
    
    // MARK: - Private Methods
    
    private func saveSchedule() {
        scheduleStore.saveSchedule(schedule)
    }
}

#Preview {
    SettingsView()
}

