import Foundation
import Observation

@MainActor
@Observable
class HealthPermissionViewModel {
    
    enum PermissionState: Equatable {
        case idle
        case requesting
        case authorized
        case denied
        case error(String)
    }
    
    var state: PermissionState = .idle
    var averageSteps: Int = 0
    var potentialCredits: Int = 0
    
    private let healthService: HealthDataProviding
    private let calculator: StepCreditsCalculator
    
    init(healthService: HealthDataProviding? = nil, 
         calculator: StepCreditsCalculator? = nil) {
        self.healthService = healthService ?? HealthKitService()
        self.calculator = calculator ?? StepCreditsCalculator()
    }
    
    func requestAccess() async {
        state = .requesting
        
        do {
            try await healthService.requestAuthorization()
            
            // After auth, fetch data immediately to show the user
            // We use 7 days as a good average
            let steps = try await healthService.fetchAverageDailySteps(over: 7)
            let credits = calculator.calculateCredits(for: steps)
            
            averageSteps = steps
            potentialCredits = credits
            state = .authorized
            
        } catch {
            // Only set error state if it's a genuine error (like device not supported).
            // HealthKit typically doesn't throw for "Denied" on read, it just returns empty data.
            // But if requestAuthorization fails (e.g. info.plist missing), it throws.
            state = .error(error.localizedDescription)
        }
    }
}

