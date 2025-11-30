import Foundation
import FamilyControls

class LocalManagedAppsStore: ManagedAppsStoring {
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let storageKey = "zeno.store.managedApps"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func loadConfig() -> ManagedAppsConfig {
        guard let data = defaults.data(forKey: storageKey),
              let config = try? decoder.decode(ManagedAppsConfig.self, from: data) else {
            return ManagedAppsConfig.empty
        }
        return config
    }
    
    func saveConfig(_ config: ManagedAppsConfig) {
        if let data = try? encoder.encode(config) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    func updateSelection(_ selection: FamilyActivitySelection) {
        var config = loadConfig()
        config.selection = selection
        saveConfig(config)
        
        // Also save to shared storage for extensions
        SharedBlockingState.shared.saveAppSelection(selection)
    }
    
    func logUnlock(duration: Int, cost: Int, appName: String?) {
        var config = loadConfig()
        let session = UnlockSession(
            timestamp: Date(),
            durationMinutes: duration,
            appName: appName,
            costInSteps: cost
        )
        config.unlockHistory.append(session)
        saveConfig(config)
    }
}
