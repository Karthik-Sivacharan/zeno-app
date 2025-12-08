import SwiftUI
import FamilyControls

@Observable
class AppPickerViewModel {
    var selection = FamilyActivitySelection()
    
    // MARK: - Schedule State
    
    /// Start time for blocking schedule
    var scheduleStartTime: Date
    
    /// End time for blocking schedule
    var scheduleEndTime: Date
    
    /// Active days for blocking
    var activeDays: Set<Weekday>
    
    // MARK: - Dependencies
    
    private let appsStore: ManagedAppsStoring
    private let scheduleStore: BlockingScheduleStoring
    
    // MARK: - Init
    
    init(
        appsStore: ManagedAppsStoring = LocalManagedAppsStore(),
        scheduleStore: BlockingScheduleStoring = LocalBlockingScheduleStore()
    ) {
        self.appsStore = appsStore
        self.scheduleStore = scheduleStore
        
        // Load existing app selection
        let config = appsStore.loadConfig()
        self.selection = config.selection
        
        // Load existing schedule or use defaults
        let schedule = scheduleStore.schedule
        self.scheduleStartTime = schedule.startTimeAsDate
        self.scheduleEndTime = schedule.endTimeAsDate
        self.activeDays = schedule.activeDays
    }
    
    // MARK: - Computed Properties
    
    var selectedCount: Int {
        selection.applicationTokens.count + 
        selection.categoryTokens.count + 
        selection.webDomainTokens.count
    }
    
    /// Formatted display string for start time
    var formattedStartTime: String {
        formatTime(scheduleStartTime)
    }
    
    /// Formatted display string for end time
    var formattedEndTime: String {
        formatTime(scheduleEndTime)
    }
    
    /// Summary of active days (e.g., "Every day" or "Mon-Fri")
    var activeDaysSummary: String {
        if activeDays.count == 7 {
            return "Every day"
        } else if activeDays == [.monday, .tuesday, .wednesday, .thursday, .friday] {
            return "Weekdays"
        } else if activeDays == [.saturday, .sunday] {
            return "Weekends"
        } else {
            // List short names
            let sorted = activeDays.sorted { $0.rawValue < $1.rawValue }
            return sorted.map { $0.shortLabel }.joined(separator: ", ")
        }
    }
    
    /// Check if the current schedule configuration is valid
    var isScheduleValid: Bool {
        scheduleEndTime > scheduleStartTime && !activeDays.isEmpty
    }
    
    // MARK: - Actions
    
    /// Saves both app selection and schedule, then registers with OS
    func saveSelection() {
        appsStore.updateSelection(selection)
        
        let schedule = buildSchedule()
        scheduleStore.saveSchedule(schedule)
        
        // Register the schedule with DeviceActivity for OS-level enforcement
        AppBlockingService.shared.registerBlockingSchedule(schedule)
    }
    
    /// Toggles a day on or off
    func toggleDay(_ day: Weekday) {
        if activeDays.contains(day) {
            // Don't allow removing the last day
            if activeDays.count > 1 {
                activeDays.remove(day)
            }
        } else {
            activeDays.insert(day)
        }
    }
    
    /// Validates and adjusts end time if start time changes
    func validateStartTimeChange() {
        // Ensure at least 1 hour gap
        let minEnd = Calendar.current.date(byAdding: .hour, value: 1, to: scheduleStartTime) ?? scheduleStartTime
        if scheduleEndTime < minEnd {
            scheduleEndTime = minEnd
        }
    }
    
    /// Validates and adjusts start time if end time changes
    func validateEndTimeChange() {
        // Ensure at least 1 hour gap
        let maxStart = Calendar.current.date(byAdding: .hour, value: -1, to: scheduleEndTime) ?? scheduleEndTime
        if scheduleStartTime > maxStart {
            scheduleStartTime = maxStart
        }
    }
    
    // MARK: - Private Helpers
    
    private func buildSchedule() -> BlockingSchedule {
        let calendar = Calendar.current
        return BlockingSchedule(
            startHour: calendar.component(.hour, from: scheduleStartTime),
            startMinute: calendar.component(.minute, from: scheduleStartTime),
            endHour: calendar.component(.hour, from: scheduleEndTime),
            endMinute: calendar.component(.minute, from: scheduleEndTime),
            activeDays: activeDays
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
