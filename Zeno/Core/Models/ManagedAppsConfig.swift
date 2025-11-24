import Foundation

struct ManagedAppsConfig: Codable, Equatable {
    /// List of app names or IDs that are manually tracked/blocked
    var manualSelection: [String]
    
    /// History of unlocks for today (reset daily or kept for history)
    /// For MVP, we might just keep a list.
    var unlockHistory: [UnlockSession]
    
    static let empty = ManagedAppsConfig(manualSelection: [], unlockHistory: [])
}

struct UnlockSession: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    let timestamp: Date
    let durationMinutes: Int
    let appName: String?
    let costInSteps: Int
}

