import Foundation
import FamilyControls

/// Manages shared state between the main app and extensions via App Groups.
/// This enables the DeviceActivityMonitor extension to reapply shields when unlock sessions expire.
final class SharedBlockingState {
    
    // MARK: - Singleton
    
    static let shared = SharedBlockingState()
    
    // MARK: - App Group Configuration
    
    /// The App Group identifier - must match in all targets' entitlements
    static let appGroupIdentifier = "group.co.karthik.Zeno"
    
    /// Keys for shared UserDefaults
    private enum Keys {
        static let appSelection = "zeno.shared.appSelection"
        static let isBlocking = "zeno.shared.isBlocking"
        static let unlockExpiresAt = "zeno.shared.unlockExpiresAt"
        static let unlockDuration = "zeno.shared.unlockDuration"
        static let unlockStartedAt = "zeno.shared.unlockStartedAt"
        static let blockingSchedule = "zeno.shared.blockingSchedule"
    }
    
    // MARK: - Properties
    
    /// Shared UserDefaults for App Group
    private let sharedDefaults: UserDefaults?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Init
    
    private init() {
        self.sharedDefaults = UserDefaults(suiteName: Self.appGroupIdentifier)
        
        if sharedDefaults == nil {
            print("[SharedBlockingState] WARNING: Could not initialize App Group UserDefaults")
        }
    }
    
    // MARK: - App Selection
    
    /// Saves the app selection to shared storage so extensions can access it
    func saveAppSelection(_ selection: FamilyActivitySelection) {
        guard let defaults = sharedDefaults else { return }
        
        do {
            let data = try encoder.encode(selection)
            defaults.set(data, forKey: Keys.appSelection)
        } catch {
            print("[SharedBlockingState] ERROR encoding app selection: \(error)")
        }
    }
    
    /// Loads the app selection from shared storage
    func loadAppSelection() -> FamilyActivitySelection? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: Keys.appSelection) else {
            return nil
        }
        
        do {
            return try decoder.decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("[SharedBlockingState] ERROR decoding app selection: \(error)")
            return nil
        }
    }
    
    // MARK: - Blocking Schedule
    
    /// Saves the blocking schedule to shared storage so extensions can check active days
    func saveSchedule(_ schedule: BlockingSchedule) {
        guard let defaults = sharedDefaults else { return }
        
        do {
            let data = try encoder.encode(schedule)
            defaults.set(data, forKey: Keys.blockingSchedule)
        } catch {
            print("[SharedBlockingState] ERROR encoding schedule: \(error)")
        }
    }
    
    /// Loads the blocking schedule from shared storage
    func loadSchedule() -> BlockingSchedule? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: Keys.blockingSchedule) else {
            return nil
        }
        
        do {
            return try decoder.decode(BlockingSchedule.self, from: data)
        } catch {
            print("[SharedBlockingState] ERROR decoding schedule: \(error)")
            return nil
        }
    }
    
    // MARK: - Blocking State
    
    /// Whether apps are currently blocked
    var isBlocking: Bool {
        get { sharedDefaults?.bool(forKey: Keys.isBlocking) ?? false }
        set { sharedDefaults?.set(newValue, forKey: Keys.isBlocking) }
    }
    
    // MARK: - Unlock Session
    
    /// When the current unlock session expires
    var unlockExpiresAt: Date? {
        get { sharedDefaults?.object(forKey: Keys.unlockExpiresAt) as? Date }
        set {
            if let date = newValue {
                sharedDefaults?.set(date, forKey: Keys.unlockExpiresAt)
            } else {
                sharedDefaults?.removeObject(forKey: Keys.unlockExpiresAt)
            }
        }
    }
    
    /// When the current unlock session started
    var unlockStartedAt: Date? {
        get { sharedDefaults?.object(forKey: Keys.unlockStartedAt) as? Date }
        set {
            if let date = newValue {
                sharedDefaults?.set(date, forKey: Keys.unlockStartedAt)
            } else {
                sharedDefaults?.removeObject(forKey: Keys.unlockStartedAt)
            }
        }
    }
    
    /// Duration of the current unlock session in minutes
    var unlockDuration: Int {
        get { sharedDefaults?.integer(forKey: Keys.unlockDuration) ?? 0 }
        set { sharedDefaults?.set(newValue, forKey: Keys.unlockDuration) }
    }
    
    // MARK: - Session Management
    
    /// Start an unlock session
    func startUnlockSession(duration: Int, expiresAt: Date) {
        isBlocking = false
        unlockStartedAt = Date()
        unlockExpiresAt = expiresAt
        unlockDuration = duration
    }
    
    /// End the unlock session (reblock)
    func endUnlockSession() {
        isBlocking = true
        unlockStartedAt = nil
        unlockExpiresAt = nil
        unlockDuration = 0
    }
    
    /// Check if there's an active unlock session
    var hasActiveUnlockSession: Bool {
        guard let expiresAt = unlockExpiresAt else { return false }
        return Date() < expiresAt
    }
    
    /// Remaining time in the current unlock session (in seconds)
    var remainingUnlockTime: TimeInterval {
        guard let expiresAt = unlockExpiresAt else { return 0 }
        return max(0, expiresAt.timeIntervalSinceNow)
    }
}

