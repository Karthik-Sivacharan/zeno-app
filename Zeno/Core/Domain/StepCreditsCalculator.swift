import Foundation

struct StepCreditsCalculator {
    /// Configuration for the calculator
    struct Configuration {
        /// Number of steps required to earn a unit of time
        var stepsPerUnit: Int = 1000
        /// Minutes earned per unit of steps
        var minutesPerUnit: Int = 10
        
        static let `default` = Configuration()
    }
    
    let config: Configuration
    
    init(config: Configuration = .default) {
        self.config = config
    }
    
    /// Calculates the credit minutes for a given number of steps
    /// - Parameter steps: The total step count
    /// - Returns: The equivalent minutes earned
    func calculateCredits(for steps: Int) -> Int {
        guard steps > 0 else { return 0 }
        // Formula: (steps / stepsPerUnit) * minutesPerUnit
        // Using Double for precision during calculation, then flooring
        let ratio = Double(config.minutesPerUnit) / Double(config.stepsPerUnit)
        let minutes = Double(steps) * ratio
        return Int(minutes)
    }
}





