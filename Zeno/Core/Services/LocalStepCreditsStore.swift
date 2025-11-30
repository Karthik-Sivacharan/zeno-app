import Foundation

// MARK: - Local Implementation (UserDefaults)

class LocalStepCreditsStore: StepCreditsStoring {
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let storageKey = "zeno.store.dailyLedger"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func loadLedger(for date: Date) -> DailyStepLedger {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        guard let data = defaults.data(forKey: storageKey),
              let ledger = try? decoder.decode(DailyStepLedger.self, from: data) else {
            return DailyStepLedger.empty(for: normalizedDate)
        }
        
        // Check if the stored ledger is for the requested date.
        // If not (e.g., stored ledger is yesterday), return a fresh one for today.
        if !Calendar.current.isDate(ledger.date, inSameDayAs: normalizedDate) {
            return DailyStepLedger.empty(for: normalizedDate)
        }
        
        return ledger
    }
    
    func saveLedger(_ ledger: DailyStepLedger) {
        if let data = try? encoder.encode(ledger) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    func spendCredits(minutes: Int) throws {
        var ledger = loadLedger(for: Date())
        
        guard ledger.creditsAvailable >= minutes else {
            throw StepCreditsError.insufficientCredits
        }
        
        ledger.creditsSpent += minutes
        saveLedger(ledger)
    }
    
    func refundCredits(minutes: Int) {
        var ledger = loadLedger(for: Date())
        // Reduce spent credits (can't go below 0)
        ledger.creditsSpent = max(0, ledger.creditsSpent - minutes)
        saveLedger(ledger)
    }
    
    func updateSteps(count: Int) {
        var ledger = loadLedger(for: Date())
        ledger.stepsSynced = count
        saveLedger(ledger)
    }
}

