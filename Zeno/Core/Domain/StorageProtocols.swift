import Foundation
import FamilyControls

// MARK: - Step Credits Store Protocol

protocol StepCreditsStoring {
    /// Loads the ledger for a specific date. 
    /// If no ledger exists for that date, it should return a new empty one.
    func loadLedger(for date: Date) -> DailyStepLedger
    
    /// Saves the ledger state.
    func saveLedger(_ ledger: DailyStepLedger)
    
    /// Convenience: Spends credits on the current ledger (today).
    func spendCredits(minutes: Int) throws
    
    /// Convenience: Updates the step count for today.
    func updateSteps(count: Int)
}

enum StepCreditsError: Error {
    case insufficientCredits
    case ledgerNotFound
}

// MARK: - User Profile Store Protocol

protocol UserProfileStoring {
    var profile: UserProfile { get }
    func updateProfile(_ transform: (inout UserProfile) -> Void)
    func saveProfile(_ profile: UserProfile)
}

// MARK: - Managed Apps Store Protocol

protocol ManagedAppsStoring {
    func loadConfig() -> ManagedAppsConfig
    func saveConfig(_ config: ManagedAppsConfig)
    func logUnlock(duration: Int, cost: Int, appName: String?)
    func updateSelection(_ selection: FamilyActivitySelection)
}
