import Foundation

class LocalUserProfileStore: UserProfileStoring {
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let storageKey = "zeno.store.userProfile"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var profile: UserProfile {
        get {
            guard let data = defaults.data(forKey: storageKey),
                  let profile = try? decoder.decode(UserProfile.self, from: data) else {
                return UserProfile.default
            }
            return profile
        }
    }
    
    func updateProfile(_ transform: (inout UserProfile) -> Void) {
        var current = profile
        transform(&current)
        saveProfile(current)
    }
    
    func saveProfile(_ profile: UserProfile) {
        if let data = try? encoder.encode(profile) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

