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

/// Monitors device activity intervals and reapplies shields when unlock sessions expire.
/// This runs at the OS level, guaranteeing execution even when the app is closed.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    private let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Unlock session started - shields already removed by main app
    }
    
    /// THIS IS THE KEY METHOD - reapplies shields when unlock time expires
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // When the unlock session ends, reapply shields
        if activity.rawValue == "zeno.unlock.session" {
            reapplyShields()
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
    
    // MARK: - Shield Application
    
    /// Reapplies shields to all apps/categories stored in shared App Group
    private func reapplyShields() {
        // Load the stored app selection from shared App Group
        guard let sharedDefaults = UserDefaults(suiteName: "group.co.karthik.Zeno") else {
            return
        }
        
        // Load the FamilyActivitySelection from shared storage
        guard let selectionData = sharedDefaults.data(forKey: "zeno.shared.appSelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData) else {
            return
        }
        
        // Apply shields (block app access)
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        // Block notifications from shielded apps (no distractions)
        store.shield.applicationNotifications = selection.applicationTokens
        store.shield.webDomainNotifications = selection.webDomainTokens
        
        // Update shared state
        sharedDefaults.set(true, forKey: "zeno.shared.isBlocking")
        sharedDefaults.removeObject(forKey: "zeno.shared.unlockExpiresAt")
    }
}
