import Foundation
import Observation
import FamilyControls

@Observable
class HomeViewModel {
    var steps: Int = 0
    var creditsEarned: Int = 0
    var creditsSpent: Int = 0
    var creditsAvailable: Int = 0
    var stepsAvailable: Int = 0
    
    var blockedAppsCount: Int = 0
    var blockedCategoriesCount: Int = 0
    var blockedWebDomainsCount: Int = 0
    
    var errorMessage: String? = nil
    
    private let healthService: HealthDataProviding
    private let stepStore: StepCreditsStoring
    private let appsStore: ManagedAppsStoring
    
    // Hardcoded for display purposes as it is private in Ledger
    private let stepsPerMinute: Int = 100
    
    init(
        healthService: HealthDataProviding = HealthKitService(),
        stepStore: StepCreditsStoring = LocalStepCreditsStore(),
        appsStore: ManagedAppsStoring = LocalManagedAppsStore()
    ) {
        self.healthService = healthService
        self.stepStore = stepStore
        self.appsStore = appsStore
    }
    
    func loadData() async {
        // 1. Load Apps Config (Always load this, independent of HealthKit)
        let config = appsStore.loadConfig()
        await MainActor.run {
            self.blockedAppsCount = config.selection.applicationTokens.count
            self.blockedCategoriesCount = config.selection.categoryTokens.count
            self.blockedWebDomainsCount = config.selection.webDomainTokens.count
        }
        
        do {
            // 2. Fetch Steps
            // Note: fetchTodaySteps returns 0 if permissions are not granted or data is missing.
            let steps = try await healthService.fetchTodaySteps()
            
            // 3. Update Store
            stepStore.updateSteps(count: steps)
            
            // 4. Load Ledger
            let ledger = stepStore.loadLedger(for: Date())
            
            await MainActor.run {
                self.steps = ledger.stepsSynced
                self.creditsEarned = ledger.creditsEarned
                self.creditsSpent = ledger.creditsSpent
                self.creditsAvailable = ledger.creditsAvailable
                self.stepsAvailable = ledger.creditsAvailable * stepsPerMinute
                self.errorMessage = nil // Clear previous errors if successful
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                // Even on error, try to load local ledger if possible (it might have old data)
                let ledger = stepStore.loadLedger(for: Date())
                self.steps = ledger.stepsSynced
                self.creditsEarned = ledger.creditsEarned
                self.creditsSpent = ledger.creditsSpent
                self.creditsAvailable = ledger.creditsAvailable
                self.stepsAvailable = ledger.creditsAvailable * stepsPerMinute
            }
        }
    }
}
