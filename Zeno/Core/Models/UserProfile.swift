import Foundation

struct UserProfile: Codable, Equatable {
    var hasCompletedOnboarding: Bool
    var historicalWeeklyAverageSteps: Int
    var notificationsEnabled: Bool
    
    // Using a simpler representation for time interval for JSON encoding
    // Storing minutes from midnight for start and end
    var morningBlockWindowStartMinutes: Int? // e.g., 480 for 8:00 AM
    var morningBlockWindowDurationMinutes: Int? // e.g., 60 for 1 hour
    
    static let `default` = UserProfile(
        hasCompletedOnboarding: false,
        historicalWeeklyAverageSteps: 0,
        notificationsEnabled: false,
        morningBlockWindowStartMinutes: nil,
        morningBlockWindowDurationMinutes: nil
    )
}

