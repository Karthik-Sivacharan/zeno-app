import Foundation

protocol HealthDataProviding {
    var isHealthDataAvailable: Bool { get }
    func requestAuthorization() async throws
    func fetchAverageDailySteps(over pastDays: Int) async throws -> Int
    func fetchTodaySteps() async throws -> Int
    
    /// Returns an AsyncStream that emits today's cumulative step count
    /// whenever new step samples are added to HealthKit.
    /// The stream emits an initial value immediately, then updates in real-time.
    func observeTodaySteps() -> AsyncStream<Int>
    
    /// Stops the step observation query. Call when app goes to background.
    func stopObservingSteps()
}

