## Cursor Rules – Zeno

### 1. General Principles

- **Code quality**: Prefer simple, readable, and maintainable code over cleverness. Follow DRY and KISS.
- **Type safety**: Avoid `Any` and force unwraps (`!`) unless absolutely necessary and clearly commented.
- **No silent failures**: Handle errors explicitly; avoid swallowing errors without at least a comment explaining why.
- **Scope**: iOS, iPhone-only, Swift + SwiftUI. No UIKit unless explicitly agreed it is needed.

### 2. Project Structure & Architecture

- **Architecture**: Lightweight MVVM-style:
  - `View` (SwiftUI) + `ViewModel` (`ObservableObject`) + `Service`/`Repository` protocols.
- **Folders / groups**:
  - `Features/Onboarding`, `Features/Home`, `Features/Blocking`,
  - `Core/DesignSystem`, `Core/Services`, `Core/Models`.
- **Abstractions**:
  - Define protocols for HealthKit, persistence, and (future) network/backend, for example:
    - `HealthDataProviding`, `StepCreditsStore`, `UserProfileStore`, `RemoteConfigProviding`.
  - Views depend on protocols, not concrete implementations.

### 3. Swift & SwiftUI Conventions

- **Language**:
  - Use the latest stable Swift supported by the project’s Xcode version.
  - Prefer `struct` over `class` for models; use `enum` for small state machines and view states.
- **SwiftUI patterns**:
  - Use `@State`, `@StateObject`, `@ObservedObject`, and `@EnvironmentObject` appropriately.
  - Keep side effects in view models or services, not directly in `View` bodies.
- **Naming**:
  - Views end with `View` (for example, `HomeView`, `OnboardingExplainerView`).
  - View models end with `ViewModel`.
  - Services end with `Service` or `Client`.
- **Async work**:
  - Prefer `async/await` instead of nested completion handlers.
  - Long-running work stays off the main thread; UI updates on the main actor.

### 4. Data, Persistence, and Backend Readiness

- **Local-first**:
  - MVP uses local storage only (for example, `UserDefaults` / `AppStorage` or a simple persistence wrapper).
- **Backend-ready**:
  - All persistence goes through repositories or stores behind protocols.
  - No direct `UserDefaults` access from views; use dedicated storage abstractions.
- **Models**:
  - Define explicit models for `UserProfile`, `StepBalance`, `AppLimit`, and `SessionStats`.
  - Prefer immutable structs; perform mutations via view models or services.

### 5. HealthKit, Screen Time, and Privacy

- **HealthKit**:
  - Read-only access to step count; request the minimum necessary permissions.
  - Wrap HealthKit access in a dedicated service that conforms to `HealthDataProviding`.
  - Handle “permission denied” with clear UI states and a simple retry path.
- **Screen Time / blocking**:
  - Be honest: Zeno cannot fully block apps like Screen Time can.
  - Zeno’s role is to coach and assist using guidance, instructions, and links, while tracking credits.
- **Privacy & data**:
  - No networking in the MVP without an explicit decision and documentation.
  - If networking is added later, document what is sent, why, and how it is stored.

### 6. Design System and UI

- **Token-first**:
  - All colors, typography, spacing, radii, shadows, and sizing MUST use design tokens from `ZenoTokens`.
  - Do not hard-code visual values inside views.
  - Refer to `.cursor/rules/design-system.mdc` for strict usage rules.
- **Visual standards**:
  - Respect WCAG 2.1 AA contrast ratios.
  - Maintain clear text hierarchy (display, title, body, label).
- **Components**:
  - Extract reusable components for buttons, cards, etc.
  - Components map internal states directly to semantic/brand tokens (e.g., `ColorBase.brand500`) rather than using a separate "Component Token" layer.
- **Brand integration**:
  - Keep design system structure stable; plug brand identity into `ColorBase` values.

> Note: For any future web UIs or docs sites, always use Tailwind v4 syntax and never Tailwind v3.

### 7. Testing, Errors, and Logging

- **Testing focus (MVP)**:
  - Favor unit tests for pure logic (for example, steps-to-minutes mapping and daily reset rules).
  - UI tests are optional early on; avoid untested complex logic.
- **Error handling**:
  - Show simple, human-readable error messages for user-facing failures where appropriate.
  - Use lightweight logging in development; avoid noisy `print` statements in committed code unless wrapped in `#if DEBUG`.

### 8. Git and Collaboration

- **Commits**:
  - Prefer small, focused commits with clear messages (for example, `Add step-credit model and mapping logic`).
- **Branches**:
  - Use feature branches for changes that touch multiple features or files.
- **Docs**:
  - Capture larger or non-obvious decisions in `docs/` (for example, `DECISIONS.md` or comments in the PRD and architecture docs).


