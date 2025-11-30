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

- Implement:
  - ~~HealthKit service (`HealthDataProviding` implementation for steps).~~
  - ~~Local storage layer (`StepCreditsStore`, `UserProfileStore`, `ManagedAppsStore`) using a simple local persistence mechanism.~~
  - ~~`StepCreditsCalculator` with the initial 1,000 steps → 10 minutes mapping.~~
- Vertical slice:
  - 🟡 **A simple internal-only screen or debug card showing:**
    - ~~Today's steps from HealthKit (shown in HealthPermissionView).~~
    - ~~Computed credits in minutes (shown in HealthPermissionView).~~

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
- Vertical slice:
  - ~~First-time user can go from app install to Home (Simplified flow).~~

### Phase 4.5 – Blocking Schedule (Next Step) ❌ NOT STARTED

> **Note:** This phase will add a scheduling screen to onboarding where users configure *when* their apps should be blocked (time-of-day + days-of-week).

- Build:
  - ❌ **Blocking Schedule screen in onboarding flow.**
    - User selects start time (e.g., 9:00 AM) and end time (e.g., 10:00 PM).
    - User selects which days (Mon-Sun) to apply blocking.
  - ❌ **Store schedule in `BlockingScheduleStore` (local persistence).**
  - ❌ **Update `AppBlockingService` to respect schedule.**
    - Automatically block apps during scheduled hours.
    - Automatically unblock outside of scheduled hours (no credits needed).
- Connect:
  - ❌ **DeviceActivityMonitor extension to enforce schedule even when app is closed.**
- Vertical slice:
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
- Vertical slice:
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
- Connect:
  - ✅ **Uses same `HKAnchoredObjectQuery` for real-time updates.**
  - ✅ **On dismiss, Home view reflects updated credits.**
- Vertical slice:
  - ✅ **User with 0 credits taps "Walk Now", walks around, sees minutes tick up, dismisses, and can now unlock apps.**

#### Nice-to-Haves (Future)
- 🎉 **Haptic feedback** when earning a new minute.
- 📱 **Keep screen awake** during Walk Now mode (`UIApplication.shared.isIdleTimerDisabled`).
- 🏃 **Animated walking icon** that bounces with step updates.
- 🎯 **Goal setting** ("I want to earn 5 more minutes" → shows progress to goal).
- 🔔 **Notification** when user has earned enough to unlock their preferred duration.

### Phase 6 – Unblock Flow (Credits-Based) ✅ COMPLETE

- Implement:
  - ✅ **Unblock controls on Home screen (duration chips + button).**
  - ✅ **Logic for spending credits to unblock for selected duration.**
  - ✅ **Duration chips only show affordable options.**
  - ✅ **"No credits" callout when user has zero credits.**
  - ✅ **Live countdown timer showing time remaining during unlock session.**
  - ✅ **Early re-lock with credit refund (unused time returned to credits).**
  - ✅ **Handling session expiration and auto-relock.**
  - ✅ **OS-level DeviceActivityMonitor for guaranteed reblocking (works even when app is closed).**
- Vertical slice:
  - ✅ **You can spend credits to unlock apps for X minutes and see credits decrease accordingly.**
  - ✅ **You can re-lock early and get unused time refunded.**
  - ✅ **Apps automatically re-lock when timer expires, even if Zeno is closed.**

### Phase 7 – Polish, Feedback, and Personal Testing ❌ NOT STARTED

- Refine:
  - ❌ **Microcopy and messaging.**
  - ❌ **Visual design alignment.**
- Personal test:
  - ❌ **Run Zeno on your own device for multiple days.**

### Post-MVP / Future Improvements 🔮

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

1. **Phase 7: Polish & Personal Testing**
   - Refine microcopy and messaging.
   - Visual design alignment.
   - Run Zeno on device for multiple days.

2. **Phase 4.5: Blocking Schedule** (Optional)
   - Add a new onboarding step for users to configure blocking hours.
   - Implement `BlockingScheduleStore` for persisting schedule data.
   - Wire up `AppBlockingService` to respect the schedule.

**Nice-to-Haves (Future Enhancements):**

- 🎉 **Haptic feedback** when earning a minute in Walk Now.
- 📱 **Keep screen awake** during Walk Now mode.
- 🏃 **Animated walking icon** that bounces with step updates.
- 🎯 **Goal setting** ("I want to earn X minutes" with progress).
- 🔔 **Notification** when enough credits earned.
