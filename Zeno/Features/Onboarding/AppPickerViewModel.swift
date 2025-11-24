import SwiftUI
import FamilyControls

@Observable
class AppPickerViewModel {
    var selection = FamilyActivitySelection()
    
    private let store: ManagedAppsStoring
    
    init(store: ManagedAppsStoring = LocalManagedAppsStore()) {
        self.store = store
        // Load existing selection if any
        let config = store.loadConfig()
        self.selection = config.selection
    }
    
    var selectedCount: Int {
        selection.applicationTokens.count + 
        selection.categoryTokens.count + 
        selection.webDomainTokens.count
    }
    
    func saveSelection() {
        store.updateSelection(selection)
    }
}

