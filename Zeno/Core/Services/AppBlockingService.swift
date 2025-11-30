import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Service responsible for blocking and unblocking apps using Screen Time APIs.
/// Uses ManagedSettings to apply shields to selected apps/categories.
/// Uses DeviceActivityCenter to schedule OS-level monitoring for guaranteed reblocking.
class AppBlockingService {
    
    // MARK: - Singleton (for ManagedSettingsStore state persistence)
    static let shared = AppBlockingService()
    
    // MARK: - Properties
    
    /// The ManagedSettingsStore is used to apply shields to apps.
    private let store = ManagedSettingsStore()
    
    /// DeviceActivityCenter schedules OS-level monitoring
    private let activityCenter = DeviceActivityCenter()
    
    /// Shared state for cross-process communication with extensions
    private let sharedState = SharedBlockingState.shared
    
    /// Track if apps are currently blocked
    private(set) var isBlocking: Bool = false
    
    /// The duration in minutes for the current unblock session
    private(set) var currentUnblockDuration: Int = 0
    
    /// When the current unblock session started
    private(set) var unblockStartedAt: Date?
    
    /// When the current unblock session expires
    private(set) var unblockExpiresAt: Date?
    
    private let appsStore: ManagedAppsStoring
    
    // MARK: - Activity Name
    
    /// The activity name used for unlock session monitoring
    private let unlockSessionActivity = DeviceActivityName("zeno.unlock.session")
    
    // MARK: - Init
    
    init(appsStore: ManagedAppsStoring = LocalManagedAppsStore()) {
        self.appsStore = appsStore
        // On init, apply shields based on stored state
        restoreBlockingState()
    }
    
    // MARK: - Public Methods
    
    /// Blocks all apps/categories from the stored ManagedAppsConfig selection.
    /// This applies a shield that prevents the user from opening these apps.
    func blockApps() {
        let config = appsStore.loadConfig()
        let selection = config.selection
        
        // Apply shields to the selected apps and categories
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        // Stop any active monitoring
        stopActivityMonitoring()
        
        isBlocking = true
        unblockStartedAt = nil
        unblockExpiresAt = nil
        currentUnblockDuration = 0
        
        // Save blocking state to both local and shared storage
        UserDefaults.standard.set(true, forKey: "zeno.blocking.isActive")
        UserDefaults.standard.removeObject(forKey: "zeno.blocking.startedAt")
        UserDefaults.standard.removeObject(forKey: "zeno.blocking.expiresAt")
        UserDefaults.standard.removeObject(forKey: "zeno.blocking.duration")
        
        // Update shared state for extensions
        sharedState.endUnlockSession()
        
        // Save app selection to shared storage so extensions can reapply shields
        sharedState.saveAppSelection(selection)
    }
    
    /// Temporarily unblocks apps for a specified duration.
    /// Schedules OS-level monitoring to guarantee reblocking even if app is closed.
    /// - Parameter minutes: How long to unblock apps for
    func unblockApps(for minutes: Int) {
        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        isBlocking = false
        currentUnblockDuration = minutes
        unblockStartedAt = Date()
        unblockExpiresAt = Date().addingTimeInterval(TimeInterval(minutes * 60))
        
        // Save state to local storage
        UserDefaults.standard.set(false, forKey: "zeno.blocking.isActive")
        UserDefaults.standard.set(unblockStartedAt, forKey: "zeno.blocking.startedAt")
        UserDefaults.standard.set(unblockExpiresAt, forKey: "zeno.blocking.expiresAt")
        UserDefaults.standard.set(minutes, forKey: "zeno.blocking.duration")
        
        // Update shared state for extensions
        sharedState.startUnlockSession(duration: minutes, expiresAt: unblockExpiresAt!)
        
        // Save app selection to shared storage so extension can reapply shields
        let config = appsStore.loadConfig()
        sharedState.saveAppSelection(config.selection)
        
        // Schedule OS-level monitoring (works even when app is closed)
        scheduleActivityMonitoring(for: minutes)
        
        // Also schedule in-app reblock as backup (for when app is open)
        scheduleInAppReblock(afterSeconds: minutes * 60)
    }
    
    /// Immediately re-blocks apps (user manually ends unblock session)
    func reblockAppsNow() {
        blockApps()
    }
    
    /// Returns the remaining minutes in the current unblock session (rounded up).
    /// Returns 0 if not in an unblock session.
    var remainingMinutes: Int {
        guard let expiresAt = unblockExpiresAt, Date() < expiresAt else { return 0 }
        let remainingSeconds = expiresAt.timeIntervalSinceNow
        // Round up to nearest minute (user gets full minute back)
        return Int(ceil(remainingSeconds / 60.0))
    }
    
    /// Returns the minutes already used in the current session.
    var usedMinutes: Int {
        return currentUnblockDuration - remainingMinutes
    }
    
    /// Check if we're in an active unblock session
    var isInUnblockSession: Bool {
        guard let expiresAt = unblockExpiresAt else { return false }
        return Date() < expiresAt
    }
    
    /// Remaining time in the current unblock session (in seconds)
    var remainingUnblockTime: TimeInterval {
        guard let expiresAt = unblockExpiresAt else { return 0 }
        return max(0, expiresAt.timeIntervalSinceNow)
    }
    
    // MARK: - Device Activity Monitoring
    
    /// Schedules OS-level activity monitoring that will trigger the extension when time expires.
    /// This works even when the app is closed or the device is locked.
    private func scheduleActivityMonitoring(for minutes: Int) {
        // Stop any existing monitoring first
        stopActivityMonitoring()
        
        let now = Date()
        let endTime = now.addingTimeInterval(TimeInterval(minutes * 60))
        
        // Create schedule components
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endTime)
        
        // Create the schedule
        // DeviceActivitySchedule requires the interval to be within a single day
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false // One-time monitoring
        )
        
        do {
            try activityCenter.startMonitoring(unlockSessionActivity, during: schedule)
            print("[AppBlockingService] Activity monitoring scheduled for \(minutes) minutes")
        } catch {
            print("[AppBlockingService] ERROR scheduling activity monitoring: \(error)")
            // Fall back to in-app timer only
        }
    }
    
    /// Stops any active device activity monitoring
    private func stopActivityMonitoring() {
        activityCenter.stopMonitoring([unlockSessionActivity])
    }
    
    // MARK: - Private Methods
    
    private func restoreBlockingState() {
        let wasBlocking = UserDefaults.standard.bool(forKey: "zeno.blocking.isActive")
        
        if let expiresAt = UserDefaults.standard.object(forKey: "zeno.blocking.expiresAt") as? Date {
            // We were in an unblock session
            if Date() < expiresAt {
                // Still in unblock session - restore all state
                isBlocking = false
                unblockExpiresAt = expiresAt
                unblockStartedAt = UserDefaults.standard.object(forKey: "zeno.blocking.startedAt") as? Date
                currentUnblockDuration = UserDefaults.standard.integer(forKey: "zeno.blocking.duration")
                
                // Re-schedule the in-app reblock
                let remainingSeconds = Int(expiresAt.timeIntervalSinceNow)
                if remainingSeconds > 0 {
                    scheduleInAppReblock(afterSeconds: remainingSeconds)
                }
                // Note: DeviceActivity monitoring should still be active from before
            } else {
                // Unblock session expired, re-block
                blockApps()
            }
        } else if wasBlocking {
            // Was blocking, restore
            blockApps()
        }
    }
    
    /// Schedules an in-app reblock as a backup (for when app is in foreground)
    private func scheduleInAppReblock(afterSeconds seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(seconds)) { [weak self] in
            // Only reblock if we're still in the same unblock session
            guard let self = self, !self.isBlocking else { return }
            self.blockApps()
        }
    }
}
