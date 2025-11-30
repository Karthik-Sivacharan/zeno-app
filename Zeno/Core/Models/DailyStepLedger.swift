import Foundation

/// Represents the daily balance of steps and credits.
struct DailyStepLedger: Codable, Equatable {
    /// The date this ledger represents (normalized to start of day)
    let date: Date
    
    /// Total steps synced from HealthKit for this day
    var stepsSynced: Int
    
    /// Total minutes spent unlocking apps today
    var creditsSpent: Int
    
    // MARK: - Configuration (Could be moved to a Config object later)
    private static let stepsPerMinute: Int = 100 // 1000 steps = 10 mins
    
    // MARK: - Computed Logic
    
    /// Total minutes earned based on steps
    var creditsEarned: Int {
        return stepsSynced / Self.stepsPerMinute
    }
    
    /// Minutes available to spend
    var creditsAvailable: Int {
        return max(0, creditsEarned - creditsSpent)
    }
    
    static func empty(for date: Date = Date()) -> DailyStepLedger {
        return DailyStepLedger(date: Calendar.current.startOfDay(for: date), stepsSynced: 0, creditsSpent: 0)
    }
}

