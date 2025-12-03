## Zeno – MVP Product Requirements (PRD)

### 1. Product Overview

- **Product name**: Zeno
- **Platform**: iOS, iPhone only (SwiftUI)
- **Concept**: Zeno turns your steps into “credits” that you can spend to unlock time on your most distracting apps. Walk first, then scroll.

### 2. Problem & Motivation

- **Problem**: Many people open apps like Instagram, TikTok, and YouTube by default, especially in the morning, leading to “brain rot” and lost time. Existing tools (Screen Time) are either too blunt, too easy to override, or not emotionally aligned with “earn your time”.
- **Why now**:
  - Health awareness and screen time awareness are both high.
  - People already track steps but don’t connect them directly to attention and focus.
  - There’s a gap between strict blocking apps and total freedom.

### 3. Target User

- **Primary user**: Young professionals / students who feel their social apps are draining time and focus, and are motivated enough to experiment with a gentle, behavior-first tool.
- **Context of use**:
  - Especially vulnerable moments: first thing in the morning, in bed, between tasks.
  - Wants a simple, low-friction way to change habits, not a complex productivity system.

### 4. Core Idea

- **Mechanic**: Walking generates credits (from Apple Health steps). Credits convert into minutes of allowed usage on chosen “brain rot” apps.
- **Initial formula**:
  - 1,000 steps → 10 minutes of app time.
  - Simple, easy to explain, adjustable later.
- **Loop**:
  1. User chooses 2–3 distracting apps.
  2. User sets a morning “no-scroll” window.
  3. Zeno reads steps from HealthKit and shows how many minutes they’ve earned.
  4. User “spends” credits to unlock app time (guided by Zeno plus Screen Time).
  5. Zeno gives feedback on how well they stuck to the plan.

### 5. Goals & Non-Goals (MVP)

- **Goals (MVP)**:
  - Validate that the “walk to unlock” mechanic feels intuitive and motivating.
  - Let a single user (you) run the full loop end-to-end on their own iPhone.
  - Make onboarding and education very clear: what Zeno can and cannot control on iOS.
  - Design the app so a backend or watch app can be added later without big rewrites.

- **Non-goals (MVP)**:
  - Perfectly enforcing hard blocks like Apple’s own Screen Time.
  - Multi-device sync, sharing, or social features.
  - Detailed analytics or history beyond a basic “today / recent days” view.
  - Cross-platform support (Android, web, watchOS) in v1.

### 6. Technical Constraints & Assumptions

- **Blocking limitations**:
  - A normal iOS app cannot fully control or hard-block third-party apps like Instagram or TikTok.
  - Zeno will coach and assist the user to set up Screen Time / Focus / Shortcuts and will:
    - Suggest which apps to limit.
    - Suggest how long limits should be, based on credits.
    - Provide in-app “blocker” and “unlock” UX for the user to follow.
- **Data & privacy**:
  - HealthKit: read step count only (no write), minimal scope.
  - Local-only storage for MVP (UserDefaults or similar, abstracted via protocols for future backend).
  - No external servers, no accounts required beyond Apple / Google sign-in if included.

### 7. High-Level Feature List (MVP)

#### 7.1 Onboarding & Education

- Splash screen with Zeno brand and one-liner.
- 2–3 explainer pages covering:
  - Problem: brain rot / doomscrolling.
  - Solution: walk steps to earn app time.
  - How it works technically and honestly (what Zeno can and can’t do).
- Gentle hand-off into permissions and setup.

#### 7.2 Auth / Account (Lightweight)

- For MVP, optional:
  - Sign in with Apple or Google (pick whichever is simpler to implement first; likely Sign in with Apple).
- Purpose:
  - Mostly future-proofing for later sync / multi-device; for MVP, might be minimal or even skipped if it adds too much friction.
- All core functionality should work without heavy backend assumptions.

#### 7.3 Permissions & Setup

- **HealthKit permission**:
  - Pre-permission explainer screen.
  - Request read access to step count.
  - Handle “Don’t Allow”: show fallback and retry flow.
- **Notifications permission (optional)**:
  - To nudge user to walk before unlocking, and do morning check-ins.
- **Screen Time guidance**:
  - Show simple steps to:
    - Pick 2–3 distracting apps.
    - Set up morning blocking window.
    - Set app time limits that map to Zeno credits.

#### 7.4 App Usage Insight & App Selection

- Simple summary of current behavior:
  - “Top 3 apps by screen time today” – if technical access is too limited, approximate via:
    - Manual selection list of common apps (Instagram, TikTok, YouTube, X, etc.).
    - Or, ask user to confirm which 3 they want to focus on.
- Screen that shows:
  - Chosen apps.
  - Daily “goal” versus allowed time per app (based on credits).

#### 7.5 Credit System (Steps → Minutes)

- Read today’s steps from HealthKit and compute:
  - `creditsMinutes = (steps / 1000) * 10` (configurable later).
- Rules:
  - Daily reset at local midnight (simplest v1).
  - Optional cap on maximum minutes banked (for example, 120 minutes) to prevent “binge banking”.
- UX:
  - Clear explanation of what the numbers mean:
    - “You’ve walked 3,200 steps today → 30 minutes of app time.”

#### 7.6 Home Screen (Daily Loop)

- Shows:
  - Today’s steps and how many minutes that gives.
  - Which apps are “managed” by Zeno.
  - How many minutes you’ve already “spent” versus remaining credit.
- Key actions:
  - “Walk more” nudges.
  - “Adjust apps” (change which apps are managed).
  - “View / edit morning block schedule” (with guidance back to Screen Time settings).

#### 7.7 In-App “Block” & “Unlock” UX (Within Zeno)

- Conceptual blocker screen that appears when:
  - User is in “no-scroll” morning window or has 0 credits.
- Shows:
  - Current credits (minutes available).
  - Guidance: “Walk ~X steps (Y minutes) to earn Z minutes”.
  - A button to “Use credits to unlock app time” (which in practice corresponds to user adjusting Screen Time limit or following instructions).
- When credits run out:
  - Show “Time’s up” state.
  - Reinforce behavior gently, suggest walking again.

### 8. Success Metrics (For Personal MVP Test)

- **Behavioral signals**:
  - You feel more resistance to opening doomscroll apps in the morning.
  - You take intentional walks or movement to earn time.
- **Simple numbers to track** (manually or via UI):
  - Percentage of days you scroll after walking at least a minimum step count (for example, 1,000).
  - Average morning screen time before versus after enabling Zeno.
  - Number of times per week you ignore Zeno and override Screen Time.

### 9. Future Considerations (Post-MVP)

- Apple Watch companion app for more natural step tracking and nudges.
- Backend for:
  - Syncing across devices.
  - More detailed history and analytics.
- Richer integrations with Screen Time or Shortcuts, as APIs allow.
- Social accountability (friends and shared goals).
- Experiments with different conversion rates and game mechanics.





