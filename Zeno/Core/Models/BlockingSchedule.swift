import Foundation

// MARK: - Weekday Enum

/// Represents days of the week for schedule configuration.
/// Raw values match `Calendar.component(.weekday)` (1 = Sunday, 7 = Saturday).
enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    /// Short display label (S, M, T, W, T, F, S)
    var shortLabel: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
    
    /// Full day name for accessibility
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    /// Returns the current weekday
    static var today: Weekday {
        let component = Calendar.current.component(.weekday, from: Date())
        return Weekday(rawValue: component) ?? .sunday
    }
}

// MARK: - Blocking Schedule

/// User's preferred blocking schedule configuration.
/// Apps are blocked only during the scheduled time window on active days.
/// Outside this window, apps are freely accessible.
struct BlockingSchedule: Codable, Equatable {
    
    // MARK: - Time Properties
    
    /// Start hour (0-23). Default: 7 (7:00 AM)
    var startHour: Int
    
    /// Start minute (0-59). Default: 0
    var startMinute: Int
    
    /// End hour (0-23). Default: 21 (9:00 PM)
    var endHour: Int
    
    /// End minute (0-59). Default: 0
    var endMinute: Int
    
    /// Days when blocking is active. Default: all days.
    var activeDays: Set<Weekday>
    
    // MARK: - Default Configuration
    
    /// Default schedule: 7:00 AM to 9:00 PM, all days active
    static let `default` = BlockingSchedule(
        startHour: 7,
        startMinute: 0,
        endHour: 21,
        endMinute: 0,
        activeDays: Set(Weekday.allCases)
    )
    
    // MARK: - Computed Properties
    
    /// Returns the start time as a Date (today with the specified hour/minute)
    var startTimeAsDate: Date {
        Calendar.current.date(
            bySettingHour: startHour,
            minute: startMinute,
            second: 0,
            of: Date()
        ) ?? Date()
    }
    
    /// Returns the end time as a Date (today with the specified hour/minute)
    var endTimeAsDate: Date {
        Calendar.current.date(
            bySettingHour: endHour,
            minute: endMinute,
            second: 0,
            of: Date()
        ) ?? Date()
    }
    
    /// Formatted start time string (e.g., "7:00 AM")
    var formattedStartTime: String {
        formatTime(hour: startHour, minute: startMinute)
    }
    
    /// Formatted end time string (e.g., "9:00 PM")
    var formattedEndTime: String {
        formatTime(hour: endHour, minute: endMinute)
    }
    
    /// Check if blocking is currently active based on time and day
    var isCurrentlyActive: Bool {
        let now = Date()
        let calendar = Calendar.current
        
        // Check if today is an active day
        let todayWeekday = calendar.component(.weekday, from: now)
        guard let weekday = Weekday(rawValue: todayWeekday),
              activeDays.contains(weekday) else {
            return false
        }
        
        // Check if current time is within the schedule
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTotalMinutes = currentHour * 60 + currentMinute
        
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        
        return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes < endTotalMinutes
    }
    
    /// Total minutes in the schedule window
    var scheduleDurationMinutes: Int {
        let startTotal = startHour * 60 + startMinute
        let endTotal = endHour * 60 + endMinute
        return max(0, endTotal - startTotal)
    }
    
    // MARK: - Validation
    
    /// Minimum allowed end time based on start time (must be at least 1 hour after)
    var minimumEndTime: Date {
        Calendar.current.date(byAdding: .hour, value: 1, to: startTimeAsDate) ?? startTimeAsDate
    }
    
    /// Check if the schedule is valid (end time > start time)
    var isValid: Bool {
        let startTotal = startHour * 60 + startMinute
        let endTotal = endHour * 60 + endMinute
        return endTotal > startTotal && !activeDays.isEmpty
    }
    
    // MARK: - Mutating Methods
    
    /// Updates the start time from a Date picker value
    mutating func setStartTime(from date: Date) {
        let calendar = Calendar.current
        startHour = calendar.component(.hour, from: date)
        startMinute = calendar.component(.minute, from: date)
        
        // Validate: ensure end time is still after start time
        let startTotal = startHour * 60 + startMinute
        let endTotal = endHour * 60 + endMinute
        
        if endTotal <= startTotal {
            // Push end time to at least 1 hour after start
            let newEndTotal = startTotal + 60
            endHour = min(23, newEndTotal / 60)
            endMinute = newEndTotal % 60
            
            // If we hit midnight, cap at 11:59 PM
            if endHour == 23 && endMinute > 59 {
                endMinute = 59
            }
        }
    }
    
    /// Updates the end time from a Date picker value
    mutating func setEndTime(from date: Date) {
        let calendar = Calendar.current
        let newHour = calendar.component(.hour, from: date)
        let newMinute = calendar.component(.minute, from: date)
        
        // Validate: ensure end time is after start time
        let startTotal = startHour * 60 + startMinute
        let newEndTotal = newHour * 60 + newMinute
        
        if newEndTotal > startTotal {
            endHour = newHour
            endMinute = newMinute
        }
    }
    
    /// Toggles a day on or off
    mutating func toggleDay(_ day: Weekday) {
        if activeDays.contains(day) {
            // Don't allow removing the last day
            if activeDays.count > 1 {
                activeDays.remove(day)
            }
        } else {
            activeDays.insert(day)
        }
    }
    
    // MARK: - Private Helpers
    
    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }
}


