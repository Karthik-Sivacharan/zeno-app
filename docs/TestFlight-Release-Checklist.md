# Zeno – TestFlight Release Checklist

This document tracks everything needed to get Zeno approved for TestFlight distribution.

---

## Version 1.0 – MVP Release

### 🔐 Apple Developer Account Setup

- [ ] **Enroll in Apple Developer Program** ($99/year)
  - URL: https://developer.apple.com/programs/
  - Use same Apple ID as your Xcode account
  - Takes ~48 hours for approval

- [ ] **Register App ID** in Developer Portal
  - Identifiers → + → App IDs
  - Bundle ID: `co.karthik.Zeno`
  - Enable capabilities:
    - [ ] App Groups
    - [ ] HealthKit
    - [ ] Family Controls

- [ ] **Register App Group**
  - Identifiers → + → App Groups
  - Identifier: `group.co.karthik.Zeno`

- [ ] **Register Extension App IDs**
  - `co.karthik.Zeno.ZenoShieldExtension`
  - `co.karthik.Zeno.ZenoShieldAction`
  - `co.karthik.Zeno.ZenoDeviceMonitor`

---

### 📱 Xcode Project Configuration

- [ ] **Main App (Zeno) Capabilities**
  - [ ] HealthKit
  - [ ] Family Controls
  - [ ] App Groups → `group.co.karthik.Zeno`

- [ ] **ZenoDeviceMonitor Capabilities**
  - [ ] Family Controls
  - [ ] App Groups → `group.co.karthik.Zeno`

- [ ] **ZenoShieldExtension Capabilities**
  - [ ] Family Controls

- [ ] **ZenoShieldAction Capabilities**
  - [ ] Family Controls

- [ ] **Signing & Certificates**
  - [ ] All targets use "Automatically manage signing"
  - [ ] All targets have correct Team selected
  - [ ] No provisioning profile errors

---

### 📄 App Store Connect Setup

- [ ] **Create App in App Store Connect**
  - URL: https://appstoreconnect.apple.com
  - Click + → New App
  - Platform: iOS
  - Name: Zeno
  - Primary Language: English
  - Bundle ID: Select `co.karthik.Zeno`
  - SKU: `zeno-ios-v1`

- [ ] **App Information**
  - [ ] Privacy Policy URL (required for HealthKit apps)
  - [ ] App Category: Health & Fitness
  - [ ] Content Rights: Does not contain third-party content

- [ ] **App Privacy (Data Collection)**
  - [ ] Health & Fitness → Steps (Linked to User)
  - [ ] Usage Data → App interactions (Not Linked)

---

### 🏥 HealthKit Requirements

- [ ] **Info.plist descriptions** (already added)
  - `NSHealthShareUsageDescription`
  - `NSHealthUpdateUsageDescription`

- [ ] **HealthKit Entitlement** enabled

- [ ] **Privacy Policy** must mention:
  - What health data is collected (steps)
  - How it's used (to calculate unlock credits)
  - That data stays on device (not uploaded)

---

### 🛡️ Screen Time API Requirements

- [ ] **Family Controls Entitlement** on all relevant targets

- [ ] **Request Screen Time Permission** in app
  - Uses `AuthorizationCenter.shared.requestAuthorization(for: .individual)`

- [ ] **App Review Notes** (explain to Apple reviewer):
  ```
  This app uses Screen Time APIs to help users manage their phone usage:
  
  1. User selects apps they want to limit
  2. User earns "unlock credits" by walking (HealthKit steps)
  3. User can temporarily unblock apps by spending credits
  4. When time expires, apps are blocked again
  
  To test:
  1. Grant HealthKit permission for Steps
  2. Grant Screen Time permission  
  3. Select at least one app to block
  4. Walk to earn credits (or we've pre-loaded test credits)
  5. Use credits to unlock apps for 2-15 minutes
  ```

---

### 🖼️ Assets Required

- [ ] **App Icon** (1024x1024) - Already have ✅

- [ ] **Screenshots** (required for TestFlight review)
  - [ ] 6.7" (iPhone 15 Pro Max): 1290 x 2796 px
  - [ ] 6.5" (iPhone 14 Plus): 1284 x 2778 px
  - [ ] 5.5" (iPhone 8 Plus): 1242 x 2208 px
  - Minimum 1 screenshot, recommend 3-5

- [ ] **App Preview Video** (optional but helpful)

---

### 📝 Build & Upload

- [ ] **Version & Build Numbers**
  - Version: 1.0.0
  - Build: 1
  - Increment build number for each upload

- [ ] **Archive the App**
  - Product → Archive
  - Select "Distribute App"
  - Choose "App Store Connect"
  - Upload

- [ ] **TestFlight Processing**
  - Wait for "Processing" to complete (~5-30 min)
  - App appears in TestFlight tab

- [ ] **Add Test Information**
  - Beta App Description
  - Feedback Email
  - Test Notes for reviewers

- [ ] **Submit for Beta Review**
  - First build requires review (~24-48 hours)
  - Subsequent builds usually auto-approved

---

### ✅ Pre-Upload Testing Checklist

- [ ] App launches without crash
- [ ] Onboarding flow completes
- [ ] HealthKit permission works
- [ ] Screen Time permission works
- [ ] App picker shows and saves selection
- [ ] Steps are fetched and credits calculated
- [ ] Unblock flow works (timer, shields)
- [ ] Re-lock early refunds credits
- [ ] App works after force quit and relaunch
- [ ] Shield appears on blocked apps
- [ ] DeviceActivityMonitor reblocks when timer expires

---

### 🚫 Common Rejection Reasons (Avoid These)

1. **Missing Privacy Policy** - Required for HealthKit
2. **Unclear App Purpose** - Explain in review notes
3. **Crash on Launch** - Test thoroughly
4. **Incomplete Functionality** - All features must work
5. **Missing Usage Description** - All permission prompts need strings

---

## Version 1.1 – Future Improvements

### Planned Features
- [ ] Dynamic Island Live Activity (timer display)
- [ ] Blocking Schedule (time-of-day restrictions)
- [ ] Widget showing steps/credits
- [ ] Apple Watch companion app

### Additional Requirements
- [ ] Widget Extension (if adding widgets)
- [ ] WatchKit Extension (if adding watch app)
- [ ] ActivityKit entitlement (for Dynamic Island)

---

## Version 1.2 – Polish & Analytics

### Planned Features
- [ ] Streak tracking
- [ ] Weekly stats
- [ ] Insights/suggestions

### Additional Requirements
- [ ] Consider analytics SDK (privacy-friendly)
- [ ] Update privacy policy if collecting analytics

---

## Quick Reference

| What | Where |
|------|-------|
| Developer Portal | https://developer.apple.com |
| App Store Connect | https://appstoreconnect.apple.com |
| TestFlight (iOS) | Download from App Store |
| Provisioning Profiles | Xcode → Preferences → Accounts |

---

## Notes

- TestFlight builds expire after **90 days**
- Can have up to **10,000 external testers**
- Internal testers (your team) don't need review
- External testers require Beta App Review

---

*Last Updated: November 26, 2025*



