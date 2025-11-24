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

### Phase 3 – Data & Integration Foundations 🟡 PARTIAL

- Implement:
  - ~~HealthKit service (`HealthDataProviding` implementation for steps).~~
  - ❌ **Local storage layer (`StepCreditsStore`, `UserProfileStore`, `ManagedAppsStore`)** using a simple local persistence mechanism.
  - ~~`StepCreditsCalculator` with the initial 1,000 steps → 10 minutes mapping.~~
- Vertical slice:
  - ❌ **A simple internal-only screen or debug card showing:**
    - ~~Today's steps from HealthKit (partially shown in HealthPermissionView but not standalone).~~
    - ~~Computed credits in minutes (partially shown in HealthPermissionView but not standalone).~~

### Phase 4 – Onboarding Flow (End-to-End Without All Polish) 🟡 PARTIAL

- Build:
  - ~~Splash screen.~~
  - ~~2–3 explainer screens.~~
  - ~~HealthKit permission prep and system dialog integration.~~
  - ❌ **Optional notifications prep screen.**
  - ❌ **App selection screen (manual list of candidate apps).**
  - ❌ **Step-to-time education screen.**
  - ❌ **Morning block schedule configuration UI (without deep Screen Time integration yet).**
- Connect:
  - ❌ **Persist selected apps and morning schedule into local stores.**
- Vertical slice:
  - ❌ **First-time user can go from app install to Home with configuration saved.**

### Phase 5 – Home Dashboard and Daily Loop ❌ NOT STARTED

- Build Home screen:
  - ❌ **Show today's step count and credits.**
  - ❌ **Show managed apps and remaining minutes per app (basic calculation).**
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
  - ❌ **Microcopy and messaging, especially around:**
    - ❌ **"Time's up."**
    - ❌ **Permission denial.**
    - ❌ **Morning no-scroll window.**
  - ~~Visual design alignment once brand tokens are defined (tokens are defined).~~
- Personal test:
  - ❌ **Run Zeno on your own device for multiple days.**
  - ❌ **Track:**
    - ❌ **How often you walk before scrolling.**
    - ❌ **Whether credits feel too generous or too strict.**
- Plan:
  - ❌ **Capture insights and decide changes to:**
    - ❌ **Step-to-time mapping.**
    - ❌ **Default morning schedule.**
    - ❌ **UX around overrides.**

---

## 🎯 Next Priority: Complete Phase 3 & 4

**Immediate next steps:**

1. **Phase 3 remaining work:**
   - Implement local storage layer (`StepCreditsStore`, `UserProfileStore`, `ManagedAppsStore`)
   - Create a debug/test screen showing today's steps and credits

2. **Phase 4 remaining work:**
   - Build notifications prep screen (optional)
   - Build app selection screen
   - Build step-to-time education screen
   - Build morning block schedule configuration UI
   - Implement persistence for selected apps and schedule

3. **Then move to Phase 5:** Build the Home Dashboard


