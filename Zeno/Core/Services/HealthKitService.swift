import Foundation
import HealthKit

// MARK: - Service

class HealthKitService: HealthDataProviding {
    
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitError.healthDataUnavailable
        }
        
        let typesToRead: Set<HKObjectType> = [stepType]
        
        // Add logging to debug in Simulator
        print("DEBUG: Requesting HealthKit authorization for: \(typesToRead)")
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            print("DEBUG: HealthKit authorization request completed successfully (note: this doesn't guarantee 'Authorized' status, just that the sheet was shown/handled).")
        } catch {
            print("DEBUG: HealthKit authorization failed with error: \(error)")
            throw error
        }
    }
    
    func fetchTodaySteps() async throws -> Int {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
    
    func fetchAverageDailySteps(over pastDays: Int) async throws -> Int {
        guard pastDays > 0 else { return 0 }
        
        let now = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -pastDays, to: now) else {
            return 0
        }
        
        // We want daily statistics
        var interval = DateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: Calendar.current.startOfDay(for: now),
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let statsCollection = results else {
                    continuation.resume(returning: 0)
                    return
                }
                
                var totalSteps: Double = 0
                var daysWithData = 0
                
                statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        totalSteps += sum.doubleValue(for: HKUnit.count())
                        daysWithData += 1
                    }
                }
                
                let average = daysWithData > 0 ? totalSteps / Double(daysWithData) : 0
                continuation.resume(returning: Int(average))
            }
            
            healthStore.execute(query)
        }
    }
}

enum HealthKitError: Error {
    case healthDataUnavailable
    case queryFailed
}

