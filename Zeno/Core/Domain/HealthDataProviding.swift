import Foundation

protocol HealthDataProviding {
    var isHealthDataAvailable: Bool { get }
    func requestAuthorization() async throws
    func fetchAverageDailySteps(over pastDays: Int) async throws -> Int
    func fetchTodaySteps() async throws -> Int
}

