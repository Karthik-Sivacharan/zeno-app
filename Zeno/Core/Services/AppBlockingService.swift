import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Service responsible for blocking and unblocking apps using Screen Time APIs.
/// Uses ManagedSettings to apply shields to selected apps/categories.
/// Uses DeviceActivityCenter to schedule OS-level monitoring for:
/// - Blocking schedule (daily repeating based on user's configured times)
/// - Unlock sessions (one-time monitoring when user spends credits)
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
    private let scheduleStore: BlockingScheduleStoring
    
    // MARK: - Activity Names
    
    /// Activity name for the daily blocking schedule
    private let blockingScheduleActivity = DeviceActivityName("zeno.blocking.schedule")
    
    /// Activity name for temporary unlock sessions (when user spends credits)
    private let unlockSessionActivity = DeviceActivityName("zeno.unlock.session")
    
    // MARK: - Init
    
    init(
        appsStore: ManagedAppsStoring = LocalManagedAppsStore(),
        scheduleStore: BlockingScheduleStoring = LocalBlockingScheduleStore()
    ) {
        self.appsStore = appsStore
        self.scheduleStore = scheduleStore
        // On init, restore blocking state and register schedule
        restoreBlockingState()
    }
    
    // MARK: - Schedule Registration
    
    /// Registers the blocking schedule with DeviceActivity for OS-level enforcement.
    /// Call this when:
    /// - App launches (after onboarding)
    /// - User changes schedule in settings
    /// - Schedule needs to be refreshed
    func registerBlockingSchedule(_ schedule: BlockingSchedule) {
        // Stop any existing schedule monitoring
        activityCenter.stopMonitoring([blockingScheduleActivity])
        
        // Save schedule to shared storage for extension access
        sharedState.saveSchedule(schedule)
        
        // Create the daily repeating schedule
        let activitySchedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: schedule.startHour, minute: schedule.startMinute),
            intervalEnd: DateComponents(hour: schedule.endHour, minute: schedule.endMinute),
            repeats: true,
            warningTime: nil
        )
        
        do {
            try activityCenter.startMonitoring(blockingScheduleActivity, during: activitySchedule)
            print("[AppBlockingService] Blocking schedule registered: \(schedule.formattedStartTime) - \(schedule.formattedEndTime)")
        } catch {
            print("[AppBlockingService] ERROR registering blocking schedule: \(error)")
        }
        
        // Immediately check and apply current state
        applyScheduleStateNow(schedule)
    }
    
    /// Checks if we're currently in a blocking window and applies the correct state.
    /// Called after schedule registration or app foreground.
    func applyScheduleStateNow(_ schedule: BlockingSchedule? = nil) {
        let currentSchedule = schedule ?? scheduleStore.schedule
        
        // If user is in a manual unlock session, don't override
        if isInUnblockSession {
            return
        }
        
        if currentSchedule.isCurrentlyActive {
            // We're in the blocking window on an active day → block apps
            blockApps()
        } else {
            // Outside blocking window or inactive day → unblock apps (schedule-based)
            unblockAppsForSchedule()
        }
    }
    
    // MARK: - Blocking Methods
    
    /// Blocks all apps/categories from the stored ManagedAppsConfig selection.
    /// This applies a shield that prevents the user from opening these apps.
    func blockApps() {
        let config = appsStore.loadConfig()
        let selection = config.selection
        
        // Apply shields to the selected apps and categories
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        // Stop any unlock session monitoring (keep schedule monitoring active)
        activityCenter.stopMonitoring([unlockSessionActivity])
        
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
    
    /// Unblocks apps because the schedule window ended (not a user action).
    /// This is different from unblockApps(for:) which requires spending credits.
    func unblockAppsForSchedule() {
        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        isBlocking = false
        unblockStartedAt = nil
        unblockExpiresAt = nil
        currentUnblockDuration = 0
        
        // Save state
        UserDefaults.standard.set(false, forKey: "zeno.blocking.isActive")
        UserDefaults.standard.removeObject(forKey: "zeno.blocking.startedAt")
        UserDefaults.standard.removeObject(forKey: "zeno.blocking.expiresAt")
        UserDefaults.standard.removeObject(forKey: "zeno.blocking.duration")
        
        sharedState.isBlocking = false
    }
    
    /// Temporarily unblocks apps for a specified duration (user spends credits).
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
        
        // Schedule OS-level monitoring for unlock session (works even when app is closed)
        scheduleUnlockSessionMonitoring(for: minutes)
        
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
    
    /// Check if we're in an active unblock session (user spent credits)
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
    
    /// Schedules OS-level activity monitoring for an unlock session.
    /// This works even when the app is closed or the device is locked.
    private func scheduleUnlockSessionMonitoring(for minutes: Int) {
        // Stop any existing unlock monitoring first
        activityCenter.stopMonitoring([unlockSessionActivity])
        
        let now = Date()
        let endTime = now.addingTimeInterval(TimeInterval(minutes * 60))
        
        // Create schedule components
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endTime)
        
        // Create the schedule (one-time, non-repeating)
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        
        do {
            try activityCenter.startMonitoring(unlockSessionActivity, during: schedule)
            print("[AppBlockingService] Unlock session monitoring scheduled for \(minutes) minutes")
        } catch {
            print("[AppBlockingService] ERROR scheduling unlock monitoring: \(error)")
        }
    }
    
    /// Stops all activity monitoring
    func stopAllMonitoring() {
        activityCenter.stopMonitoring([blockingScheduleActivity, unlockSessionActivity])
    }
    
    // MARK: - Private Methods
    
    private func restoreBlockingState() {
        // First, re-register the schedule with DeviceActivity
        // This ensures schedule monitoring is active even after app restart
        let schedule = scheduleStore.schedule
        
        // Only register if user has completed onboarding (has selected apps)
        let config = appsStore.loadConfig()
        let hasSelectedApps = !config.selection.applicationTokens.isEmpty || 
                              !config.selection.categoryTokens.isEmpty
        
        if hasSelectedApps {
            // Register schedule with DeviceActivity (this also syncs to shared storage)
            registerBlockingSchedule(schedule)
        }
        
        // Now handle any in-progress unlock session
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
            }
            // If expired, applyScheduleStateNow was already called by registerBlockingSchedule
        }
    }
    
    /// Schedules an in-app reblock as a backup (for when app is in foreground)
    private func scheduleInAppReblock(afterSeconds seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(seconds)) { [weak self] in
            guard let self = self, !self.isBlocking else { return }
            
            // Check if we're still in the schedule window before reblocking
            let schedule = self.scheduleStore.schedule
            if schedule.isCurrentlyActive {
                self.blockApps()
            }
        }
    }
}
