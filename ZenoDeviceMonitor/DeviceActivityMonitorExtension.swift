//
//  DeviceActivityMonitorExtension.swift
//  ZenoDeviceMonitor
//
//  Created by Karthik Sivacharan on 11/26/25.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

/// Activity names - must match main app
private enum ActivityNames {
    static let blockingSchedule = "zeno.blocking.schedule"
    static let unlockSession = "zeno.unlock.session"
    static let realtimeMonitoring = "zeno.realtime.monitoring"
}

/// Event names - must match main app
private enum EventNames {
    static let blockedAppUsage = "zeno.blocked.app.usage"
}

/// Shared storage keys - must match main app
private enum SharedKeys {
    static let appSelection = "zeno.shared.appSelection"
    static let blockingSchedule = "zeno.shared.blockingSchedule"
    static let isBlocking = "zeno.shared.isBlocking"
    static let unlockExpiresAt = "zeno.shared.unlockExpiresAt"
}

/// App Group identifier - must match main app
private let appGroupIdentifier = "group.co.karthik.Zeno"

// MARK: - Weekday (Duplicated for Extension)

/// Represents days of the week. Raw values match Calendar.component(.weekday).
private enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    /// Returns the current weekday
    static var today: Weekday {
        let component = Calendar.current.component(.weekday, from: Date())
        return Weekday(rawValue: component) ?? .sunday
    }
}

// MARK: - BlockingSchedule (Duplicated for Extension)

/// Minimal schedule data needed by extension
private struct BlockingSchedule: Codable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var activeDays: Set<Weekday>
    
    /// Check if blocking should be active right now
    var isCurrentlyActive: Bool {
        let now = Date()
        let calendar = Calendar.current
        
        // Check if today is an active day
        guard activeDays.contains(Weekday.today) else {
            return false
        }
        
        // Check if current time is within the schedule
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTotalMinutes = currentHour * 60 + currentMinute
        
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        
        return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes < endTotalMinutes
    }
}

// MARK: - Device Activity Monitor Extension

/// Monitors device activity intervals and manages app blocking.
/// Handles two types of activity:
/// 1. Blocking schedule (daily repeating) - blocks/unblocks based on user's configured times
/// 2. Unlock session (one-time) - reblocks when user's credit-based unlock expires
///
/// This runs at the OS level, guaranteeing execution even when the app is closed.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    private let store = ManagedSettingsStore()
    
    // MARK: - Interval Start
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        switch activity.rawValue {
        case ActivityNames.blockingSchedule:
            // Blocking schedule window started → apply shields (if today is active)
            handleScheduleStart()
            
        case ActivityNames.unlockSession:
            // Unlock session started - shields already removed by main app
            break
            
        case ActivityNames.realtimeMonitoring:
            // Real-time monitoring started - shields already applied by main app
            break
            
        default:
            break
        }
    }
    
    // MARK: - Interval End
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        switch activity.rawValue {
        case ActivityNames.blockingSchedule:
            // Blocking schedule window ended → remove shields
            handleScheduleEnd()
            
        case ActivityNames.unlockSession:
            // Unlock session expired → reapply shields (if still in schedule window)
            handleUnlockSessionEnd()
            
        case ActivityNames.realtimeMonitoring:
            // Real-time monitoring ended (24-hour window) - main app will restart if needed
            break
            
        default:
            break
        }
    }
    
    // MARK: - Schedule Handlers
    
    /// Called when the daily blocking schedule interval starts
    private func handleScheduleStart() {
        guard let schedule = loadSchedule() else { return }
        
        // Only block if today is an active day
        if schedule.activeDays.contains(Weekday.today) {
            applyShields()
            updateSharedState(isBlocking: true)
        }
    }
    
    /// Called when the daily blocking schedule interval ends
    private func handleScheduleEnd() {
        removeShields()
        updateSharedState(isBlocking: false)
    }
    
    /// Called when a credit-based unlock session expires
    private func handleUnlockSessionEnd() {
        print("[DeviceMonitor] 🔄 Unlock session ended - forcing shield refresh")
        
        guard let schedule = loadSchedule() else {
            // No schedule found, just reapply shields with force refresh
            forceShieldRefresh()
            updateSharedState(isBlocking: true)
            return
        }
        
        // Only reblock if we're still in the blocking schedule window
        if schedule.isCurrentlyActive {
            // Force refresh shields to interrupt running apps
            forceShieldRefresh()
            updateSharedState(isBlocking: true)
        } else {
            print("[DeviceMonitor] Not in blocking window - not reapplying shields")
        }
    }
    
    /// Forces a shield refresh by removing and immediately reapplying shields.
    /// This may help interrupt apps that are already running.
    private func forceShieldRefresh() {
        guard let selection = loadAppSelection() else {
            print("[DeviceMonitor] No app selection found for shield refresh")
            return
        }
        
        // Step 1: Remove all shields (reset state)
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        // Step 2: Small delay to let the system process the removal
        Thread.sleep(forTimeInterval: 0.1)
        
        // Step 3: Reapply shields
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        print("[DeviceMonitor] ✅ Shield refresh complete")
    }
    
    // MARK: - Shield Management
    
    /// Applies shields to block app access
    private func applyShields() {
        guard let selection = loadAppSelection() else { return }
        
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }
    
    /// Removes all shields to allow app access
    private func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
    
    // MARK: - Shared Storage
    
    private func loadAppSelection() -> FamilyActivitySelection? {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: SharedKeys.appSelection) else {
            return nil
        }
        
        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }
    
    private func loadSchedule() -> BlockingSchedule? {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: SharedKeys.blockingSchedule) else {
            return nil
        }
        
        return try? JSONDecoder().decode(BlockingSchedule.self, from: data)
    }
    
    private func updateSharedState(isBlocking: Bool) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }
        
        defaults.set(isBlocking, forKey: SharedKeys.isBlocking)
        
        if isBlocking {
            defaults.removeObject(forKey: SharedKeys.unlockExpiresAt)
        }
    }
    
    // MARK: - Event Handlers
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle app usage events for instant blocking
        if event.rawValue == EventNames.blockedAppUsage {
            switch activity.rawValue {
            case ActivityNames.blockingSchedule:
                // App used during blocking schedule - reapply shields if not in unlock session
                handleBlockedAppUsageDetected()
                
            case ActivityNames.unlockSession:
                // App used during unlock session - check if session has expired
                handleUnlockSessionUsageCheck()
                
            default:
                break
            }
        }
    }
    
    /// Called when a blocked app is detected being used during blocking time.
    /// Reapplies shields to force immediate blocking even if app is already open.
    private func handleBlockedAppUsageDetected() {
        print("[DeviceMonitor] 🚨 Blocked app usage detected during blocking schedule")
        
        // Check if we're in an unlock session - if so, don't reblock
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            applyShields()
            return
        }
        
        if let unlockExpiresAt = defaults.object(forKey: SharedKeys.unlockExpiresAt) as? Date {
            // Check if unlock session has expired
            if Date() >= unlockExpiresAt {
                // Unlock session expired, reapply blocks
                print("[DeviceMonitor] Unlock session expired - reapplying blocks")
                forceShieldRefresh()
                updateSharedState(isBlocking: true)
            } else {
                print("[DeviceMonitor] Still in unlock session - not reapplying shields")
            }
        } else {
            // No unlock session, immediately reapply blocks
            print("[DeviceMonitor] No unlock session - reapplying blocks")
            applyShields()
        }
    }
    
    /// Called periodically when apps are being used during an unlock session.
    /// Checks if the unlock session has expired and reblocks if needed.
    private func handleUnlockSessionUsageCheck() {
        print("[DeviceMonitor] 🔍 Checking unlock session status while app is in use")
        
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let unlockExpiresAt = defaults.object(forKey: SharedKeys.unlockExpiresAt) as? Date else {
            // No unlock session found - this shouldn't happen but reblock to be safe
            print("[DeviceMonitor] No unlock session found - reblocking")
            forceShieldRefresh()
            updateSharedState(isBlocking: true)
            return
        }
        
        // Check if unlock session has expired
        if Date() >= unlockExpiresAt {
            print("[DeviceMonitor] ⏰ Unlock session expired while app in use - forcing shield refresh")
            forceShieldRefresh()
            updateSharedState(isBlocking: true)
        } else {
            let remaining = Int(unlockExpiresAt.timeIntervalSinceNow)
            print("[DeviceMonitor] Unlock session still active - \(remaining)s remaining")
        }
    }
    
    // MARK: - Warning Methods (Optional)
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
}
