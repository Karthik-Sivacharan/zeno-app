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
  - ➖ **Morning block schedule configuration UI.** (Removed for simplified MVP)
- Connect:
  - ~~Persist selected apps into local stores.~~
- Vertical slice:
  - ~~First-time user can go from app install to Home (Simplified flow).~~

### Phase 5 – Home Dashboard and Daily Loop ❌ NOT STARTED

- Build Home screen:
  - ❌ **Show today's step count and credits.**
  - ❌ **Show managed apps count (simple state for MVP).**
  - ❌ **Show morning no-scroll window status.**
  - ❌ **Provide clear empty/edge states (no permission, no steps, no apps).**
- Behavior:
  - ❌ **On app launch, Home refreshes today's steps and credits.**
  - ❌ **Handles daily reset of credits at midnight.**
- Vertical slice:
  - ❌ **You can open the app each morning and see an accurate snapshot of your steps and available credits.**

### Phase 6 – In-App Block / Unlock Coaching ❌ NOT STARTED

- Implement:
  - ❌ **Dedicated "block / unlock" view using `BlockingViewModel`.**
  - ❌ **Logic for:**
    - ❌ **Spending credits for a selected app.**
    - ❌ **Showing "time remaining" for that app.**
    - ❌ **Handling "out of time" states.**
- Coaching integration:
  - ❌ **On "use credits" action, show guidance for adjusting Screen Time limits manually.**
  - ❌ **(Optionally later) add links or automation via Shortcuts where possible.**
- Vertical slice:
  - ❌ **You can simulate the experience of "unlocking" an app for X minutes and see credits decrease accordingly.**

### Phase 7 – Polish, Feedback, and Personal Testing ❌ NOT STARTED

- Refine:
  - ❌ **Microcopy and messaging.**
  - ❌ **Visual design alignment.**
- Personal test:
  - ❌ **Run Zeno on your own device for multiple days.**

### Post-MVP / Future Improvements 🔮

- **Enhanced App Reporting:**
  - Implement `DeviceActivityReportExtension` to show app names, icons, and usage stats in the Block List.
  - Match Opal's level of detail for selected apps.

---

## 🎯 Next Priority: Complete Phase 5

**Immediate next steps:**

1. **Phase 5: Home Dashboard**
   - Build the main `HomeView` to replace the placeholder.
   - Display real data from `HealthService` and `LocalStepCreditsStore`.
   - Implement the "Credit" visualization.
