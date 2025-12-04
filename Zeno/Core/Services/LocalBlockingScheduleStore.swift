import Foundation

/// Persists the user's blocking schedule configuration to UserDefaults.
class LocalBlockingScheduleStore: BlockingScheduleStoring {
    
    // MARK: - Properties
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let storageKey = "zeno.store.blockingSchedule"
    
    // MARK: - Init
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - BlockingScheduleStoring
    
    var schedule: BlockingSchedule {
        get {
            guard let data = defaults.data(forKey: storageKey),
                  let savedSchedule = try? decoder.decode(BlockingSchedule.self, from: data) else {
                return BlockingSchedule.default
            }
            return savedSchedule
        }
    }
    
    func saveSchedule(_ schedule: BlockingSchedule) {
        if let data = try? encoder.encode(schedule) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    func updateSchedule(_ transform: (inout BlockingSchedule) -> Void) {
        var current = schedule
        transform(&current)
        saveSchedule(current)
    }
}

