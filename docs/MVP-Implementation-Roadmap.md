## Zeno MVP – Implementation Roadmap

This roadmap sequences work into small, testable phases and emphasizes vertical slices you can run on-device as early as possible.
### Phase 1 – Docs, Rules, and Design System Skeleton ✅ COMPLETE
- Finalize:
  - ~~Product PRD (`Zeno-PRD.md`).~~
  - ~~Cursor rules (`Cursor-Rules.md`).~~
  - ~~Design token architecture (`Design-Tokens-Architecture.md`).~~
  - ~~UX flow and technical architecture docs.~~
- Goal:
  - ~~Shared understanding of what we are building and how we build it.~~
  - ~~Token structure ready for brand values later.~~
### Phase 2 – Token Scaffolding and Base Components ✅ COMPLETE
- Implement:
  - ~~A simple `DesignSystem` or `ZenoTheme` in Swift that encodes:~~
    - ~~Core spacing, radius, typography, and color tokens (even with placeholder values initially).~~
  - ~~A small set of foundational components:~~
    - ~~Primary button (`ZenoButton`).~~
    - ~~Card container for onboarding/summary (tokens ready, components can use them).~~
    - ~~Text styles for titles, body, and captions (all typography tokens defined).~~
- Vertical slice:
  - ~~Build the Splash + one Explainer screen using actual tokens and base components.~~
### Phase 3 – Data & Integration Foundations ✅ COMPLETE
  - ~~HealthKit service (`HealthDataProviding` implementation for steps).~~
  - ~~Local storage layer (`StepCreditsStore`, `UserProfileStore`, `ManagedAppsStore`) using a simple local persistence mechanism.~~
  - ~~`StepCreditsCalculator` with the initial 1,000 steps → 10 minutes mapping.~~
  - 🟡 **A simple internal-only screen or debug card showing:**
    - ~~Today's steps from HealthKit (shown in HealthPermissionView).~~
    - ~~Computed credits in minutes (shown in HealthPermissionView).~~
### Phase 3.5 – Authentication (Apple Sign In) ❌ NOT STARTED
> **Purpose:** Verify user identity before onboarding. Architected for future backend integration.

**Decisions:**
- Apple Sign In only (no Google for MVP)
- Auth required to use app (no guest mode)
- Onboarding flows after successful authentication

**What We Store:**
- Apple User ID → Keychain (secure, persists across reinstalls)
- User's name + email → UserProfileStore (captured on first sign-in only)
- `hasCompletedAuth` flag → UserDefaults (for fast routing on app launch)

**Implementation:**
- ❌ **Create `AuthService` protocol** (`AuthProviding`) for abstraction
- ❌ **Implement `LocalAuthService`** (Keychain-based, no backend)
- ❌ **Build Auth Screen** with "Sign in with Apple" button
- ❌ **Handle first sign-in** — persist name/email immediately
- ❌ **Handle subsequent sign-ins** — restore from Keychain
- ❌ **Handle credential revocation** — detect and redirect to auth
- ❌ **Update app routing** — Splash → Auth (if needed) → Onboarding → Home

**Backend-Ready Architecture:**
- Protocol allows easy swap to `FirebaseAuthService` or `SupabaseAuthService`
- User ID + token can be sent to backend for account creation
- No code changes needed in Views — just swap the service implementation

**Edge Cases:**
- User declines Apple Sign In → Show auth screen again (required)
- User revokes credential in Settings → Clear local state, show auth screen
- App reinstall → Auto-restore from Keychain (silent re-auth)

### Phase 4 – Onboarding Flow (Simplified MVP) ✅ COMPLETE
- Build:
  - ~~Splash screen.~~
  - ~~Explainer screens ("Dopamine Trap", "Walk to Unlock").~~
  - ~~HealthKit permission prep and system dialog integration.~~
  - ~~Usage Estimation & Impact screens (New Scope).~~
  - ~~Screen Time permission screen.~~
  - ~~App Selection using Family Activity Picker.~~
  - ➖ **Optional notifications prep screen.** (Deferred)
- Connect:
  - ~~Persist selected apps into local stores.~~
  - ~~Auto-block selected apps immediately after onboarding.~~
  - ~~First-time user can go from app install to Home (Simplified flow).~~
### Phase 4.5 – Blocking Schedule (Next Step) ❌ NOT STARTED
> **Note:** This phase will add a scheduling screen to onboarding where users configure *when* their apps should be blocked (time-of-day + days-of-week).
  - ❌ **Blocking Schedule screen in onboarding flow.**
    - User selects start time (e.g., 9:00 AM) and end time (e.g., 10:00 PM).
    - User selects which days (Mon-Sun) to apply blocking.
  - ❌ **Store schedule in `BlockingScheduleStore` (local persistence).**
  - ❌ **Update `AppBlockingService` to respect schedule.**
    - Automatically block apps during scheduled hours.
    - Automatically unblock outside of scheduled hours (no credits needed).
  - ❌ **DeviceActivityMonitor extension to enforce schedule even when app is closed.**
  - ❌ **User can set "block social media from 9 AM - 6 PM on weekdays" and it just works.**
### Phase 5 – Home Dashboard and Daily Loop 🟡 IN PROGRESS
- Build Home screen:
  - ✅ **Show today's step count and credits.**
  - ✅ **Show managed apps count (simple state for MVP).**
  - ✅ **Unblock controls with duration selection.**
  - ✅ **Apps blocked by default after onboarding.**
  - ✅ **Show remaining unlock time during active session (live countdown timer).**
  - ✅ **User-friendly error handling (no raw HealthKit errors shown).**
  - ❌ **Provide clear empty/edge states (no permission, no steps, no apps).**
- Behavior:
  - ✅ **On app launch, Home refreshes today's steps and credits.**
  - ✅ **Real-time step updates while app is in foreground (HKAnchoredObjectQuery).**
  - ❌ **Handles daily reset of credits at midnight.**
  - ✅ **You can open the app each morning and see an accurate snapshot of your steps and available credits.**
### Phase 5.5 – "Walk Now" Real-Time Tracker ✅ COMPLETE
> **Purpose:** When users don't have enough credits, give them a motivating real-time tracker to earn more by walking.
- Build "Walk Now" Sheet:
  - ✅ **Fullscreen sheet (similar to `ActiveSessionView` design).**
  - ✅ **Shows current credits/steps user already has (so they know their starting point).**
  - ✅ **Tracks session steps in real-time (steps walked since opening the sheet).**
  - ✅ **Large display: Minutes earned this session (primary metric).**
  - ✅ **Small display: Steps walked this session (supporting info).**
  - ✅ **Progress bar toward next minute (e.g., "47/100 steps to next minute").**
  - ✅ **"Done Walking" button to dismiss and return to Home.**
- Trigger:
  - ✅ **"Walk Now" button appears when `canAffordAnyDuration == false`.**
  - ✅ **Augments the "Out of time" callout with bright green CTA.**
  - ✅ **Uses same `HKAnchoredObjectQuery` for real-time updates.**
  - ✅ **On dismiss, Home view reflects updated credits.**
  - ✅ **User with 0 credits taps "Walk Now", walks around, sees minutes tick up, dismisses, and can now unlock apps.**
### Phase 6 – Unblock Flow (Credits-Based) ✅ COMPLETE
  - ✅ **Unblock controls on Home screen (duration chips + button).**
  - ✅ **Logic for spending credits to unblock for selected duration.**
  - ✅ **Duration chips only show affordable options.**
  - ✅ **"No credits" callout when user has zero credits.**
  - ✅ **Live countdown timer showing time remaining during unlock session.**
  - ✅ **Early re-lock with credit refund (unused time returned to credits).**
  - ✅ **Handling session expiration and auto-relock.**
  - ✅ **OS-level DeviceActivityMonitor for guaranteed reblocking (works even when app is closed).**
  - ✅ **You can spend credits to unlock apps for X minutes and see credits decrease accordingly.**
  - ✅ **You can re-lock early and get unused time refunded.**
  - ✅ **Apps automatically re-lock when timer expires, even if Zeno is closed.**
### Phase 7 – Polish, Feedback, and Personal Testing ❌ NOT STARTED
- Refine:
  - ❌ **Microcopy and messaging.**
  - ❌ **Visual design alignment.**
- Personal test:
  - ❌ **Run Zeno on your own device for multiple days.**
### Phase 7.5 – Delight & Micro-Interactions ❌ NOT STARTED
> **Purpose:** Elevate Zeno from functional to delightful. These touches make the app feel alive and rewarding.
- **Haptics:**
  - ❌ **Success haptic** when unlocking apps (`.success` feedback).
  - ❌ **Soft tick haptic** when earning each new minute in Walk Now.
  - ❌ **Warning haptic** when session is about to expire (1 min warning).
  - ❌ **Impact haptic** on button presses (subtle `.light` impact).
- **Animations:**
  - ❌ **Step counter tick-up animation** (numbers animate to new value).
  - ❌ **Credit balance pulse** when credits are earned.
  - ❌ **Progress bar smooth fill** with spring animation.
  - ❌ **Walking icon bounce** that animates with step updates in Walk Now.
  - ❌ **Confetti/celebration** when user earns significant credits (e.g., 10+ minutes).
  - ❌ **Card entrance animations** (staggered fade-in on Home).
  - ❌ **Button press scale animation** (micro-interaction on tap).
  - ❌ **Timer countdown pulse** as time runs low (last 60 seconds).
- **Icons & Visual Polish:**
  - ❌ **Custom SF Symbol compositions** for key actions (walk, lock, unlock).
  - ❌ **Animated app icon** (if feasible) or polished static icon.
  - ❌ **Empty state illustrations** (friendly graphics for no-data states).
  - ❌ **Status indicator animations** (locked/unlocked state transitions).
- **Sound (Optional):**
  - ❌ **Subtle unlock sound** (optional, user-configurable).
  - ❌ **Achievement chime** when hitting milestones.
- **Screen & UX Enhancements:**
  - ❌ **Keep screen awake** during Walk Now (`UIApplication.shared.isIdleTimerDisabled`).
  - ❌ **Pull-to-refresh** with custom animation on Home.
  - ❌ **Skeleton loading states** instead of spinners.

- Vertical slice:
  - ❌ **Using Zeno feels rewarding and tactile – every interaction has feedback.**
### Phase 8 – Analytics & User Insights ❌ NOT STARTED
> **Purpose:** Understand how users interact with Zeno to inform product decisions, identify friction points, and measure engagement. Privacy-first approach — no PII collection.
- **Analytics Foundation:**
  - ❌ **Choose analytics provider** (recommended: TelemetryDeck for privacy-first, or PostHog for self-hosted).
  - ❌ **Create `AnalyticsService` protocol** for abstraction (easy to swap providers).
  - ❌ **Implement opt-in analytics consent** (respect user privacy, add toggle in Settings).
  - ❌ **Add analytics initialization** in app launch (only if user consented).
- **Core Events to Track:**
  - ❌ **Onboarding funnel:**
    - `onboarding_started` — User opened app for first time.
    - `onboarding_step_completed` — Which step (health permission, app selection, etc.).
    - `onboarding_completed` — User finished full onboarding.
    - `onboarding_abandoned` — User quit at which step.
  - ❌ **Daily engagement:**
    - `app_opened` — With context (from notification, cold start, background).
    - `steps_synced` — Step count synced (no actual count, just event).
    - `credits_earned` — Minutes earned (bucket: 0-5, 5-15, 15-30, 30+).
  - ❌ **Unlock behavior:**
    - `unlock_initiated` — Duration selected (5/10/15/30 min).
    - `unlock_completed` — Session ended naturally (timer expired).
    - `unlock_early_relock` — User re-locked early (with % time unused).
    - `walk_now_started` — User opened Walk Now sheet.
    - `walk_now_completed` — User finished walking (with minutes earned bucket).
  - ❌ **Retention signals:**
    - `day_n_active` — User opened app on day 1, 3, 7, 14, 30 post-install.
    - `feature_used` — Which features are engaged (settings, app management).
- **Privacy Considerations:**
  - ❌ **No PII collection** — No names, emails, or identifiers.
  - ❌ **Anonymous device ID** only (can be reset by user).
  - ❌ **Bucket sensitive data** — Don't send exact step counts, use ranges.
  - ❌ **Local-first aggregation** — Batch events, don't send real-time.
  - ❌ **Clear data deletion path** — User can request data deletion.
- **Dashboard & Insights:**
  - ❌ **Onboarding conversion funnel** — Where do users drop off?
  - ❌ **Daily/weekly active users** — Retention curves.
  - ❌ **Most popular unlock durations** — What do users prefer?
  - ❌ **Walk Now usage** — How often do users need to earn more credits?

- Vertical slice:
  - ❌ **You can see in a dashboard how many users completed onboarding and their 7-day retention.**
---
### Phase 8.5 – Security & Privacy Hardening ❌ NOT STARTED
> **Purpose:** Ensure user data is protected, app is resilient to attacks, and meets App Store security requirements. Essential for production deployment.
- **Data Security:**
  - ❌ **Keychain for sensitive data** — Store any tokens/secrets in Keychain, not UserDefaults.
  - ❌ **Audit local storage** — Ensure `StepCreditsStore`, `UserProfileStore` don't contain sensitive data in plain text.
  - ❌ **Implement data encryption** — Encrypt local JSON files if storing any personal data.
  - ❌ **Secure UserDefaults** — Use `kSecAttrAccessibleAfterFirstUnlock` for any sensitive defaults.
- **Input Validation & Sanitization:**
  - ❌ **Validate all user inputs** — Duration selections, any text fields.
  - ❌ **Bounds checking** — Ensure step counts, credit calculations can't overflow/underflow.
  - ❌ **Rate limiting** — Prevent rapid unlock/relock abuse.
- **App Integrity:**
  - ❌ **Jailbreak detection** (optional) — Warn users on compromised devices.
  - ❌ **Debug detection** — Disable debug features in release builds.
  - ❌ **Code obfuscation** (optional) — Protect business logic.
  - ❌ **Certificate pinning** (if using network calls) — Prevent MITM attacks.
- **Screen Time API Security:**
  - ❌ **Validate FamilyControls authorization** — Handle revoked permissions gracefully.
  - ❌ **Secure activity tokens** — Family Activity selections stored securely.
  - ❌ **Handle ManagedSettings tampering** — Detect and respond to unexpected shield removals.
- **Privacy Compliance:**
  - ❌ **App Privacy Report** — Prepare accurate App Store privacy labels.
  - ❌ **Data collection disclosure** — Clear in-app explanation of what's collected.
  - ❌ **GDPR/CCPA compliance** (if applicable) — Data export and deletion.
  - ❌ **HealthKit data handling** — Ensure health data never leaves device.
- **Secure Coding Practices:**
  - ❌ **Remove debug logging** — No sensitive data in console logs for release.
  - ❌ **Secure string handling** — No hardcoded secrets or API keys.
  - ❌ **Memory safety** — Ensure sensitive data cleared from memory when not needed.
  - ❌ **Error handling** — Don't leak internal state in error messages.
- **Authentication (Future-Proofing):**
  - ❌ **Biometric authentication option** — FaceID/TouchID to open Zeno (optional setting).
  - ❌ **App lock timeout** — Auto-lock Zeno after inactivity (optional setting).
- **Security Testing:**
  - ❌ **Static analysis** — Run security linters on codebase.
  - ❌ **Penetration testing** (optional) — Basic security audit.
  - ❌ **Dependency audit** — Check third-party libraries for vulnerabilities.

- Vertical slice:
  - ❌ **App passes App Store security review and handles all edge cases gracefully.**

---

### Post-MVP / Future Improvements 🔮
- **Notification Blocking for Shielded Apps:**
  - Screen Time's `ShieldSettings` only blocks app access, not notifications.
  - Explore alternative approaches:
    - Focus Filters (iOS 16+) — may require user to set up Focus mode.
    - Guide users to disable notifications manually in Settings.
    - Investigate if `ManagedSettingsStore` has other notification APIs.
  - Goal: Complete silence from blocked apps (no distracting notifications).
  - Optional: Add user toggle "Block notifications from managed apps" in settings.
- **Dynamic Island Live Activity:**
  - Show live countdown timer in Dynamic Island when apps are unblocked.
  - Display Zeno app logo on one side, timer on the other with app colors.
  - Create Widget Extension target with ActivityKit.
  - Requires App Groups for data sharing between main app and widget.
  - Only works on iPhone 14 Pro and later (devices with Dynamic Island).
- **Enhanced App Reporting:**

  - Implement `DeviceActivityReportExtension` to show app names, icons, and usage stats in the Block List.
  - Match Opal's level of detail for selected apps.

---


## 🎯 Next Priority: Phase 7 – Polish & Personal Testing

**Recently Completed:**

- ✅ **Live Countdown Timer** – Shows remaining unlock time with live updates.
- ✅ **Early Re-lock with Refund** – User can re-lock apps early and get unused credits back.
- ✅ **Auto-relock** – Apps automatically re-lock when timer expires.
- ✅ **User-friendly error handling** – No more raw HealthKit errors shown to users.
- ✅ **Real-Time Step Updates** – Steps update live via `HKAnchoredObjectQuery` when app is in foreground.
- ✅ **"Walk Now" Feature** – Motivational step tracker sheet when user has 0 credits.

**Immediate next steps:**

1. **Phase 5 (Finish):** Edge states + midnight credit reset
2. **Phase 7: Polish & Personal Testing**
   - Refine microcopy and messaging
   - Visual design alignment
   - Run Zeno on device for multiple days
3. **Phase 7.5: Delight & Micro-Interactions**
   - Haptics (unlock success, step ticks, button feedback)
   - Animations (counter tick-up, progress bar springs, card entrances)
   - Icons & visual polish (empty state illustrations, status transitions)
   - Screen enhancements (keep-awake in Walk Now, pull-to-refresh)
4. **Phase 8: Analytics & User Insights**
   - Set up TelemetryDeck or PostHog (privacy-first)
   - Implement opt-in consent flow
   - Track onboarding funnel, engagement, and retention events
5. **Phase 8.5: Security & Privacy Hardening**
   - Keychain for sensitive data, audit local storage
   - Input validation and bounds checking
   - App Store privacy compliance and security review prep

**Optional/Deferred:**

- **Phase 4.5: Blocking Schedule** – Time-of-day automation (can add post-launch)

**Future Enhancements (Post-MVP):**

- 🎯 **Goal setting** ("I want to earn X minutes" with progress).
- 🔔 **Notifications** when enough credits earned.
- 🏝️ **Dynamic Island Live Activity** for active sessions.
- 📊 **Enhanced App Reporting** with usage stats.
