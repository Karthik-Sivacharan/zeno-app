## Zeno UX Flow and Screens (MVP)

This document maps the end-to-end onboarding and daily loop for the Zeno MVP, including key screens and states.

### 1. High-Level Flows

1. **First-run onboarding**
   - Splash → Explainer carousel → Permissions prep → System dialogs → App selection → Step-to-time education → Schedule setup → Home.
2. **Daily loop**
   - Open app → See today’s steps and credits → Decide whether to walk or “spend” credits → Adjust apps or schedule if needed.
3. **Blocking / unlock interaction (coaching model)**
   - When the user wants to use a distracting app, Zeno shows how many credits they have and how much time that buys, and guides them to align Screen Time with that.

---

### 2. Screen List and Purpose

1. **Splash Screen**
   - Purpose: Introduce Zeno brand and core promise.
   - Content: Logo, short tagline, subtle loading or “Get started” CTA.

2. **Explainer Carousel (2–3 pages)**
   - Page 1 – Problem:
     - “Brain rot” / doomscrolling, especially in the morning.
   - Page 2 – Solution:
     - Walk steps to earn time on distracting apps.
   - Page 3 – How it works + honesty:
     - Zeno uses Apple Health steps and helps you configure Screen Time; it cannot hard-block apps itself.

3. **Permissions Prep – HealthKit**
   - Purpose: Warm the user up before the system dialog appears.
   - Content:
     - Short explanation of why steps are needed.
     - What data is read (steps only), what is not accessed.
     - Primary CTA: “Connect Apple Health”.

4. **System Dialog – Health Access (iOS)**
   - Native iOS dialog for Health permissions (not a custom screen).
   - Zeno must handle both “Allow” and “Don’t Allow”.

5. **Permissions Prep – Notifications (Optional)**
   - Purpose: Explain optional nudges (e.g. “Walk before you scroll” reminders).
   - Content:
     - Why notifications might help.
     - Option to skip for now.

6. **App Selection / Usage Focus Screen**
   - Purpose: Help user pick 2–3 “brain rot” apps to manage.
   - Content:
     - List of common candidates (Instagram, TikTok, YouTube, X, etc.).
     - Simple explanation: “Pick up to 3 apps that steal your time.”
   - States:
     - Empty: no apps selected yet.
     - Normal: one or more apps selected.

7. **Step-to-Time Education Screen**
   - Purpose: Explain the mapping from steps → minutes.
   - Content:
     - Visual representation (for example, progress meter) of 1,000 steps → 10 minutes.
     - Example day: “3,000 steps → 30 minutes total.”
   - Options:
     - Confirm understanding and continue.

8. **Blocking Schedule Setup (Morning No-Scroll)**
   - Purpose: Encourage a simple default behavior change.
   - Content:
     - Suggest a morning window (for example, wake-up to first hour of day).
     - Let user pick a time range.
   - Guidance:
     - Remind that Zeno will **help** configure Screen Time / Focus, not enforce it alone.

9. **Screen Time Setup Guidance (Optional Helper Screen)**
   - Purpose: Coach user through actual iOS settings.
   - Content:
     - Step-by-step instructions (and links where possible) to:
       - Set app limits or Downtime/Focus for selected apps.
       - Align those limits roughly with Zeno’s credit model.

10. **Home Dashboard (Main Screen)**
    - Purpose: Daily control center for Zeno.
    - Sections:
      - Today’s steps and credits (headline).
      - Managed apps list with remaining time for today.
      - Morning block status (active / inactive).
      - Suggested next action (for example, “Walk 400 steps to earn 4 more minutes”).
    - States:
      - Empty: just started day, no steps yet.
      - Normal: some steps and credits accumulated.
      - Edge: Health permission denied; show recovery path.

11. **In-App “Block / Unlock” View**
    - Purpose: Represent the moment of temptation and decision inside Zeno.
    - Content:
      - Current step count and credits.
      - Selected app and suggested allowed time.
      - CTA: “Use X minutes to unlock now” plus suggestion to walk if credits are low.
      - State when credits are exhausted: “Time’s up for today – walk more or come back tomorrow.”

12. **Settings / Preferences**
    - Purpose: Edit configuration after onboarding.
    - Content:
      - Edit selected apps.
      - Adjust step-to-time ratio (later; fixed in MVP).
      - Edit morning block schedule.
      - View privacy information and data usage.

---

### 3. Navigation Structure

- **Onboarding flow**:
  - Navigation stack for:
    - Splash → Explainers → Permission prep → App selection → Education → Schedule → Home.
  - Once completed, app should open directly to Home on subsequent launches (with a way to revisit onboarding pieces via Settings if needed).

- **Primary app structure after onboarding**:
  - Single main `Home` view as entry point.
  - Modal or pushed screens for:
    - In-app block/unlock view.
    - Settings.
    - Edit managed apps and schedule.

---

### 4. Key States and Edge Cases

#### 4.1 Health Permissions

- **Granted**:
  - Home shows step count and credits.
  - Onboarding proceeds as normal.
- **Denied**:
  - Show clear explanation card on Home:
    - “We can’t see your steps yet. To earn credits, enable step access in Settings.”
  - Offer a button with system settings link where possible.

#### 4.2 No Steps Yet Today

- State displayed on Home:
  - “You haven’t walked yet today.”
  - Suggested micro-goal (for example, “Walk 200 steps to unlock 2 minutes.”).

#### 4.3 No Apps Selected

- If user skips app selection or later removes all apps:
  - Show empty state:
    - “Pick 1–3 apps you want to manage.”
  - CTA to open the app selection screen.

#### 4.4 Out of Credits

- Home:
  - Show that remaining time is 0.
  - Encourage movement: “Walk X more steps for Y minutes.”
- In-app block view:
  - “You’re out of time for today” messaging.
  - Highlight benefits of stopping rather than overriding Screen Time.

#### 4.5 Morning No-Scroll Window

- During active window:
  - Home can emphasize “No-scroll window active” and show countdown until it ends.
  - In-app view should lean into the “walk first” narrative:
    - “You chose to protect this time. Walk a bit or wait until the window ends.”

---

### 5. Copy Principles (for Later Detailed Writing)

- Be honest about technical limitations (cannot directly hard-block apps).
- Emphasize agency and self-respect over guilt or shame.
- Keep language concise and calm, especially in moments of “blocking” or “time’s up”.


