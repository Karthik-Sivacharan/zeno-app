//
//  ShieldActionExtension.swift
//  ZenoShieldAction
//
//  Created by Karthik Sivacharan on 11/26/25.
//

import ManagedSettings
import ManagedSettingsUI

/// Handles button taps on the shield view.
/// Note: Shield Action Extensions cannot directly open other apps.
/// Both buttons will close the shield - user must manually open Zeno.
class ShieldActionExtension: ShieldActionDelegate {
    
    // MARK: - Application Shield Actions
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Close shield - user will need to manually open Zeno
            completionHandler(.close)
        case .secondaryButtonPressed:
            // Close the shield
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Category Shield Actions
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Web Domain Shield Actions
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
}
