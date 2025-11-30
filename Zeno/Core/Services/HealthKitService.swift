import Foundation
import HealthKit

// MARK: - Service

class HealthKitService: HealthDataProviding {
    
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    /// The active anchored query for real-time step observation
    private var stepObserverQuery: HKAnchoredObjectQuery?
    
    /// Current cumulative step count (used to calculate totals from incremental updates)
    private var observedStepCount: Int = 0
    
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
    
    // MARK: - Real-Time Step Observation
    
    func observeTodaySteps() -> AsyncStream<Int> {
        // Stop any existing observation first
        stopObservingSteps()
        
        return AsyncStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            // Reset observed count for new observation session
            self.observedStepCount = 0
            
            // Set up predicate for today's steps
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: nil, // Open-ended to catch new samples
                options: .strictStartDate
            )
            
            // Create anchored object query for real-time updates
            let query = HKAnchoredObjectQuery(
                type: self.stepType,
                predicate: predicate,
                anchor: nil, // Start fresh each observation session
                limit: HKObjectQueryNoLimit
            ) { [weak self] _, samples, _, _, error in
                // Initial results handler
                guard let self = self else { return }
                
                if let error = error {
                    print("DEBUG: Step observation initial query error: \(error)")
                    continuation.yield(0)
                    return
                }
                
                // Calculate initial step count from all samples
                let initialSteps = self.calculateStepsFromSamples(samples)
                self.observedStepCount = initialSteps
                
                print("DEBUG: Step observation started with \(initialSteps) steps")
                continuation.yield(initialSteps)
            }
            
            // Set up update handler for new samples
            query.updateHandler = { [weak self] _, addedSamples, _, _, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("DEBUG: Step observation update error: \(error)")
                    return
                }
                
                // Add new steps to our running total
                let newSteps = self.calculateStepsFromSamples(addedSamples)
                if newSteps > 0 {
                    self.observedStepCount += newSteps
                    print("DEBUG: Step observation update: +\(newSteps) steps, total: \(self.observedStepCount)")
                    continuation.yield(self.observedStepCount)
                }
            }
            
            // Store and execute the query
            self.stepObserverQuery = query
            self.healthStore.execute(query)
            
            // Handle stream termination
            continuation.onTermination = { [weak self] _ in
                self?.stopObservingSteps()
            }
        }
    }
    
    func stopObservingSteps() {
        if let query = stepObserverQuery {
            healthStore.stop(query)
            stepObserverQuery = nil
            print("DEBUG: Step observation stopped")
        }
    }
    
    // MARK: - Private Helpers
    
    /// Calculate total steps from an array of HKSample objects
    private func calculateStepsFromSamples(_ samples: [HKSample]?) -> Int {
        guard let samples = samples else { return 0 }
        
        var totalSteps: Double = 0
        for sample in samples {
            if let quantitySample = sample as? HKQuantitySample {
                totalSteps += quantitySample.quantity.doubleValue(for: HKUnit.count())
            }
        }
        
        return Int(totalSteps)
    }
}

enum HealthKitError: Error {
    case healthDataUnavailable
    case queryFailed
}

