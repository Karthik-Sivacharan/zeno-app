## Zeno Project Walkthrough (SwiftUI Newcomer Guide)

This tutorial is written for a **total SwiftUI beginner**. It teaches the fundamentals, then walks through how Zeno is built so you can understand and extend it confidently.

---

### A) SwiftUI Basics in 5 Minutes
- **Everything is a View:** Each screen is a tree of lightweight structs conforming to `View`.
- **State drives UI:** Change a state variable → SwiftUI re-renders the view body.
- **Modifiers:** Chain calls like `.padding(...)` or `.background(...)` to style/layout.
- **Stacks & Layout:** `VStack` (vertical), `HStack` (horizontal), `ZStack` (overlap). Use `Spacer()` to push things apart.
- **Data flow tools you’ll see here:**
  - `@State` – simple local state (primitives, small structs).
  - `@Binding` – read/write state passed from a parent (e.g., `hasCompletedOnboarding`).
  - `@Observable` (iOS 17) – for ViewModels; properties inside notify views.
  - `@Environment` – read system values (e.g., `scenePhase`).
  - `@AppStorage` – persisted user defaults with SwiftUI-friendly binding.

SwiftUI mental model: **describe the UI for the current state**; never “imperatively” mutate the UI. Change state, let SwiftUI redraw.

---

### B) Project Entry Points (Follow the Flow)
- `ZenoApp` → `ContentView` decides what to show:
  - Splash (`SplashView`)
  - Onboarding (`OnboardingFlowView`) until `hasCompletedOnboarding` flips true
  - Main app (`HomeView`) after onboarding
- This decision is driven by `@AppStorage("hasCompletedOnboarding")` so it persists across launches.

---

### C) Folder Map (What lives where)
- `Features/` — Screens & ViewModels (UI logic). Example: `Home/`, `Onboarding/`, `Settings/`, `Debug/`.
- `Core/Domain/` — Protocols and pure business logic (`HealthDataProviding`, `StepCreditsCalculator`).
- `Core/Models/` — App data structs (`DailyStepLedger`, `UserProfile`, `ManagedAppsConfig`).
- `Core/Services/` — Side-effects (HealthKit, blocking, persistence) implementing the domain protocols.
- `DesignSystem/` — Tokens + reusable components + animation modifiers. **Never hardcode styling**; always use tokens.
- `Resources/` — Fonts, SVGs, assets.

---

### D) How State & Data Flow Work Here
1) View appears → calls a ViewModel method (`loadData()`, `startObservingSteps()`).
2) ViewModel talks to Services via **protocols** (e.g., `HealthDataProviding`).
3) Services fetch or mutate models (`DailyStepLedger`, `UserProfile`, etc.).
4) ViewModel updates its properties (observable) → View re-renders.

Keep UI logic in ViewModels; keep side-effects in Services; keep calculations in Domain/Models. Views remain declarative and dumb.

---

### E) Design System (Tokens First, Always)
- Colors, spacing, radius, typography, shadows, motion are **all tokens**.
  - Prefer `ZenoSemanticTokens.*` (semantic) over `ZenoTokens.*` (primitives).
  - Examples:
    - Spacing: `ZenoSemanticTokens.Space.md`
    - Text: `.font(ZenoTokens.Typography.titleSmall)`
    - Colors: `.foregroundColor(ZenoSemanticTokens.Theme.primary)`
    - Radius: `.clipShape(RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md))`
- Reusable components live in `DesignSystem/Components` (e.g., `ZenoButton`, `ZenoTabBar`, `TimeChip`, `TodayStatsCard`). Reuse them before inventing new UI.
- Animations use `ZenoSemanticTokens.Motion` duration and easing tokens; backgrounds stay still while content animates.

---

### F) Motion Principles You’ll Feel in Code
- Backgrounds never animate; only content transitions.
- Fast by default: `Motion.Duration.fast` for most transitions; `snap` for instant feedback.
- Combine transforms: opacity + small offset for polish.
- Stagger entries (`.staggeredItem(index:isVisible:)`) instead of dropping everything at once.
- Fullscreen overlays (e.g., `WalkNowView`) enter with asymmetric move-from-bottom + fade.

---

### G) Guided Tour by Feature
**Splash → Onboarding → Home**

- **ContentView**: Holds `showSplash` and `hasCompletedOnboarding`. Shows splash first, then fades to onboarding or home.
- **OnboardingFlowView**:
  - Guides through permissions (HealthKit, Screen Time), app selection (`AppPickerView`), and baseline estimates (`UsageEstimates`).
  - Writes onboarding completion to `@AppStorage` and persists profile via `LocalUserProfileStore`.
- **HomeView + HomeViewModel**:
  - On appear: `loadData()` then `startObservingSteps()`.
  - Renders `TodayStatsCard` with steps/credits; shows shielding status header when blocking is active.
  - Floating controls: choose duration (`TimeChip`), unshield if affordable, or tap “Walk Now” to open `WalkNowView`.
  - Active sessions render fullscreen via `ActiveSessionView`; step observation and timer syncing keep it live.
- **Settings / Debug**: Light, isolated surfaces to inspect and tweak without polluting Home logic.

---

### H) Services & Models (Plain-Language Cheatsheet)
- `HealthDataProviding` → `HealthKitService`: gets steps, starts/stops observation.
- `AppBlockingService`: coordinates FamilyControls/ManagedSettings to shield/unshield selected apps.
- `DailyStepLedger`: holds steps and credits for a day; `creditsEarned` and `creditsAvailable` are computed (100 steps = 1 minute by default).
- `StepCreditsCalculator`: central place to change the step-to-minute ratio.
- Stores (`LocalStepCreditsStore`, `LocalUserProfileStore`, `LocalManagedAppsStore`): JSON in UserDefaults for MVP; swap later by conforming to the same protocols.
- `SharedBlockingState`: cross-feature shared info about current blocking/unblocking.

---

### I) Build-a-Block (Hands-On Mini Tutorial)
Goal: Add a small “streak” tile to Home showing consecutive shielded days.

1) **Add model/state (ViewModel first):**
   - In `HomeViewModel`, add a computed property:
     - `var streakText: String { "\(currentStreak) day streak" }`
     - Derive `currentStreak` from stored data (fake it first: hardcode `3` to see UI).
2) **Render in the View:**
   - In `HomeView`’s `homeTabContent` `VStack`, add a card above `TodayStatsCard`:
     - Use a `ZStack` or `VStack` with:
       - Text title using `ZenoTokens.Typography.labelSmall`
       - Value using `ZenoTokens.Typography.titleMedium`
     - Spacing via `ZenoSemanticTokens.Space.md`
     - Background: `ZenoSemanticTokens.Theme.card`, corner radius `ZenoSemanticTokens.Radius.lg`, shadow `ZenoSemanticTokens.Shadow.card`
3) **Animate in:**
   - Wrap the tile in `.staggeredItem(index: 0, isVisible: true)` to align with the existing stagger cadence.
4) **Style check:**
   - No hardcoded numbers; all tokens.
   - Background does not animate; only content fades/lifts.
5) **Replace the fake data:**
   - Add a real streak source later (e.g., compute from `DailyStepLedger` history when you persist multiple days).

What you learned: add ViewModel state → render with tokens → animate using shared modifiers → keep backgrounds stable.

---

### J) Common SwiftUI Patterns in This Codebase
- **Bindings:** `OnboardingFlowView(hasCompletedOnboarding: $hasCompletedOnboarding)` passes a writable binding down so onboarding can flip completion.
- **Environment:** `@Environment(\.scenePhase)` in `HomeView` to start/stop step observation when app foregrounds/backgrounds.
- **Safe area insets:** `safeAreaInset(edge: .bottom)` to host the tab bar and floating controls without being overlapped.
- **Transitions:** `.transition(.opacity)` for fades; custom asymmetric transitions for overlays.
- **Tasks:** `.task { await viewModel.loadData() }` to kick off async work when a view appears.

---

### K) Accessibility & Theming Quick Wins
- Use semantic text sizes (`ZenoTokens.Typography.*`) and avoid fixed font sizes.
- Respect contrast automatically by sticking to `ZenoSemanticTokens.Theme` colors.
- Provide clear tap targets with token padding; don’t shrink hit areas.
- Avoid animating backgrounds; keep durations short (150–300ms) so interactions feel instant.

---

### L) Testing & Device Notes
- Simulator: great for layout; won’t exercise HealthKit/FamilyControls.
- Physical device with entitlements: required for step syncing and app shielding.
- Quick smoke: run `ZenoUITests` to ensure launch/basic flows; use Debug tab to inspect state without hitting real services.

---

### M) How to Extend Safely (Recipe)
- New feature: create `Features/MyFeature/` with `MyFeatureView` + `MyFeatureViewModel`.
- New data source: implement the relevant protocol (e.g., `StepCreditsStoring`) and inject it where the ViewModel is created.
- New UI piece: add to `DesignSystem/Components`, powered by tokens and (if animated) shared modifiers.
- Change credit math: update `StepCreditsCalculator`; don’t duplicate math in views.

---

### N) Quick Reference Reminders
- Backgrounds stay still; animate content only.
- Tokens for every visual: spacing, colors, radius, typography, motion.
- State lives in ViewModels; Views are pure renderers.
- Protocols at boundaries; services are swappable.

---

### O) Next Steps for You
- Open `ContentView` → trace the flow into `OnboardingFlowView` and `HomeView`.
- Add the “streak” tile exercise above; verify it animates in and uses tokens.
- Try changing the step-to-minute ratio in `StepCreditsCalculator`; confirm Home updates without UI code changes.
- Inspect `DesignSystem/Components` and reuse before building new UI.

### 1) Mental Model
- **What Zeno does:** Lets users earn time-unlocks for distracting apps by walking. Steps are synced from HealthKit, converted into “credits,” and spent to temporarily unshield apps.
- **Architecture:** Features-first SwiftUI with a clean separation of UI (Views), state (ViewModels), domain logic (Domain/Models), and side-effects (Services).
- **Styling:** 100% design tokens (no magic numbers/colors). Motion uses the shared animation system (fast, purpose-driven, no animating backgrounds).

### 2) How to Run
- Open `Zeno.xcodeproj` in Xcode 15+ (iOS 17 target).
- Select the `Zeno` scheme, run on a physical device for HealthKit/FamilyControls; simulator works for UI-only flows.
- Entry point: `ZenoApp` → `ContentView` decides between splash, onboarding, or the authenticated home flow via `@AppStorage("hasCompletedOnboarding")`.

### 3) File & Layer Layout
- `Zeno/Features/` — Screens and their ViewModels (e.g., Home, Onboarding, Settings, Debug).
- `Zeno/Core/Domain/` — Pure business logic/protocols (`HealthDataProviding`, `StepCreditsCalculator`).
- `Zeno/Core/Models/` — App data structs (`DailyStepLedger`, `UserProfile`, `ManagedAppsConfig`).
- `Zeno/Core/Services/` — Side-effect implementations (`HealthKitService`, `AppBlockingService`, local stores).
- `Zeno/DesignSystem/` — Tokens and reusable UI components (buttons, tabs, chips, animation modifiers).
- `Zeno/Resources/` — Fonts, SVG illustrations, and app assets.

### 4) SwiftUI & State Conventions
- Uses modern SwiftUI (iOS 17). Views own their ViewModels via `@State private var viewModel = ...` unless injected.
- Observation: `@Observable` ViewModels (in code you’ll see stored properties instead of `@Published`). Views react via state properties.
- Navigation: `NavigationStack` patterns inside features; avoid `NavigationView`.
- No logic in `body` expressions—ViewModels expose ready-to-render state like `steps`, `creditsAvailable`, `canUnblock`.

### 5) Data & Services
- **Health**: `HealthDataProviding` → `HealthKitService` fetches steps and starts/stops observation.
- **Blocking**: `AppBlockingService` coordinates FamilyControls/ManagedSettings to shield/unshield apps.
- **Persistence**: Local `UserDefaults` JSON stores (`LocalUserProfileStore`, `LocalStepCreditsStore`, etc.) implementing protocols from `Core/Domain/`.
- **Ledger math**: `DailyStepLedger` computes `creditsEarned` and `creditsAvailable` (steps ↔ minutes), with `StepCreditsCalculator` for ratios.
- **Shared state**: `SharedBlockingState` tracks current blocking/unblocking status across features.

### 6) Design System (Tokens First)
- **Colors/Spacing/Radius/Typography**: Always use `ZenoSemanticTokens` (preferred) or `ZenoTokens` primitives—never hardcode values.
- **Components**: `DesignSystem/Components` hosts reusable pieces like `ZenoButton`, `ZenoTabBar`, `TimeChip`, `TodayStatsCard`, `ZenoSegmentedControl`.
- **Animation modifiers**: Reuse helpers in `DesignSystem/Animations/ZenoAnimationModifiers.swift` (e.g., `.staggeredItem`, `.slideUpFade`, `.shimmer`).
- **Patterns**: Stable backgrounds, animated content only; combine opacity + offset; stagger entrances; use duration tokens (`snap`, `fast`, `medium`, `slow`).

### 7) Motion Rules in Practice
- Splash to app: `ContentView` fades out splash, then fades the main flow—background remains stable.
- Tab changes: `HomeView` uses `.smooth(duration: Motion.Duration.fast)` with asymmetric transitions for content only; bottom bar stays fixed.
- Fullscreen overlays (`WalkNowView`, `ActiveSessionView`): asymmetric move-from-bottom + opacity to maintain orientation.

### 8) Key Feature Flows
- **Splash** (`SplashView`): Brief animated intro; after ~2.5s `showSplash` flips off with animation.
- **Onboarding** (`OnboardingFlowView` and content views):
  - Collects permissions (HealthKit + Screen Time), app selection (`AppPickerView`), and baseline activity estimates (`UsageEstimates`).
  - Persists completion via `hasCompletedOnboarding` and seeds profile data in `LocalUserProfileStore`.
- **Home** (`HomeView` + `HomeViewModel`):
  - On appear: `loadData()` then `startObservingSteps()`.
  - Header shows shielding status; `TodayStatsCard` displays steps/credits.
  - Floating controls let users pick an unlock duration (`TimeChip`) and unshield apps if they can afford it; otherwise “Walk Now” CTA opens `WalkNowView`.
  - Active sessions render fullscreen via `ActiveSessionView`; real-time updates come from step observation and timer syncing.
- **Settings/Debug**: Light-weight views to inspect state, toggles, and developer utilities without mixing into Home logic.

### 9) Dependency Injection Pattern
- Protocol-first: ViewModels depend on protocols (`HealthDataProviding`, `StepCreditsStoring`, `ManagedAppsStoring`).
- Concrete services are created at composition points (feature initializers or future app container). Swap implementations (e.g., mock stores) without touching views.

### 10) Persistence & Credits Model
- `DailyStepLedger`: persists steps synced and credits spent per day; computed properties expose earned/available credits.
- `StepCreditsCalculator`: converts steps to minutes (default ratio 100 steps = 1 minute; adjust centrally).
- Stores write/read JSON via `UserDefaults` keys; ready to swap for SwiftData or remote stores by conforming to the same protocols.

### 11) Styling & Accessibility Basics
- Respect WCAG AA by default through token contrast; avoid custom hex values.
- Use semantic roles in text hierarchy (`ZenoTokens.Typography`), consistent spacing (`Space.md` etc.), and rounded corners via `Radius`.
- Avoid animating backgrounds; keep interaction responsive (fast durations).
- SF Symbols for system icons; SVG assets live in `Resources/SVGs/` when custom illustrations are needed.

### 12) Testing & Debugging
- UI sanity: run `ZenoUITests` for launch/smoke; Debug tab helps inspect blocking/credits without hitting real services.
- Device-only behaviors: HealthKit and FamilyControls require physical device + proper entitlements; simulator for layout only.
- Common checks: verify step sync starts on foreground, unshield timers resume correctly after app returns to foreground, and app picker selections persist.

### 13) How to Extend Safely
- New feature: create a folder under `Features/FeatureName/` with `FeatureView` + `FeatureViewModel`, add any new models to `Core/Models`, services to `Core/Services` conforming to existing protocols.
- New component: place in `DesignSystem/Components`, powered by tokens; if animated, reuse modifiers and duration tokens.
- Change credit math: update `StepCreditsCalculator` and ensure UI reads computed properties instead of duplicating logic.
- Add data source: implement the relevant store protocol (e.g., `RemoteStepCreditsStore`) and inject it at the composition root.

### 14) Orientation Checklist (Keep This Handy)
- Backgrounds stay still; content transitions only.
- Use tokens for every visual value; no magic numbers.
- Motion is fast, purposeful, and combines opacity + subtle offset.
- State lives in ViewModels; views render already-derived values.
- Protocols for services; swap implementations without touching UI.

### 15) Phrases to Remember
- “Features own UI; Core owns logic and data.”
- “Tokens first, no hardcoded styling.”
- “Animate content, not backgrounds.”
- “Protocols at the edges; services are swappable.”

