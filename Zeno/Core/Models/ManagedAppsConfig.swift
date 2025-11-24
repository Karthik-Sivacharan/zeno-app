import Foundation
import FamilyControls

struct ManagedAppsConfig: Codable, Equatable {
    /// The set of apps, categories, and websites selected by the user to be managed.
    var selection: FamilyActivitySelection
    
    /// History of unlocks for today (reset daily or kept for history)
    var unlockHistory: [UnlockSession]
    
    static let empty = ManagedAppsConfig(selection: FamilyActivitySelection(), unlockHistory: [])
}

struct UnlockSession: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    let timestamp: Date
    let durationMinutes: Int
    let appName: String?
    let costInSteps: Int
}
