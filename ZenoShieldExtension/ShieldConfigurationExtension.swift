//
//  ShieldConfigurationExtension.swift
//  ZenoShieldExtension
//
//  Created by Karthik Sivacharan on 11/26/25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Custom Shield Configuration Extension for Zeno.
/// This provides the custom UI shown when a user tries to open a blocked app.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    // MARK: - Shield Configuration
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        createZenoShieldConfiguration(
            appName: application.localizedDisplayName ?? "This app"
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        createZenoShieldConfiguration(
            appName: application.localizedDisplayName ?? "This app"
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        createZenoShieldConfiguration(
            appName: webDomain.domain ?? "This website"
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        createZenoShieldConfiguration(
            appName: webDomain.domain ?? "This website"
        )
    }
    
    // MARK: - Private Methods
    
    /// Creates the Zeno-branded shield configuration
    private func createZenoShieldConfiguration(appName: String) -> ShieldConfiguration {
        // Define colors matching our design system (Zeno tokens)
        let backgroundColor = UIColor(red: 0.078, green: 0.110, blue: 0.094, alpha: 1.0) // Olive._900
        let primaryTextColor = UIColor(red: 0.847, green: 0.749, blue: 0.608, alpha: 1.0) // Sand._300
        let mutedTextColor = UIColor(red: 0.702, green: 0.722, blue: 0.710, alpha: 1.0) // Moss._400
        let accentColor = UIColor(red: 0.800, green: 1.0, blue: 0.0, alpha: 1.0) // Acid._400
        
        // Use true black for button text - maximum contrast on bright acid green
        let buttonTextColor = UIColor.black
        
        // Create custom icon with Zeno's acid green color
        let icon = createLockIcon()
        
        return ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: backgroundColor,
            icon: icon,
            title: ShieldConfiguration.Label(
                text: "Blocked by Zeno",
                color: primaryTextColor
            ),
            subtitle: ShieldConfiguration.Label(
                text: "\(appName) usage has been blocked.\n\nOpen Zeno to check if you've walked enough today to unblock.",
                color: mutedTextColor
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: buttonTextColor
            ),
            primaryButtonBackgroundColor: accentColor,
            secondaryButtonLabel: nil
        )
    }
    
    /// Creates a custom lock icon in Zeno's acid green color
    private func createLockIcon() -> UIImage? {
        let accentColor = UIColor(red: 0.800, green: 1.0, blue: 0.0, alpha: 1.0) // Acid._400
        
        // Use SF Symbol for a lock icon, tinted with our accent color
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .medium)
        let lockImage = UIImage(systemName: "lock.fill", withConfiguration: config)?
            .withTintColor(accentColor, renderingMode: .alwaysOriginal)
        
        return lockImage
    }
}
