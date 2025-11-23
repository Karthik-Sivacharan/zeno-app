# Zeno

**Walk first, then scroll.**

Zeno is an iOS app that turns your steps into "credits" that you can spend to unlock time on your most distracting apps. Built with SwiftUI for iOS 17.0+.

## Concept

- Walk to earn credits (1,000 steps = 10 minutes of app time)
- Choose 2–3 distracting apps to control
- Spend credits to unlock time on those apps
- Build healthier habits by connecting physical activity to screen time

## Tech Stack

- **Framework**: SwiftUI (iOS 17.0+)
- **State Management**: Observation Framework (`@Observable`)
- **Health Data**: HealthKit
- **Screen Time**: FamilyControls & ManagedSettings
- **Architecture**: MVVM with modern Swift concurrency (`async/await`)

## Project Structure

```
Zeno/
├── Core/              # Domain logic & services
├── DesignSystem/      # Design tokens & components
├── Features/          # Feature modules (Onboarding, Splash, etc.)
└── Resources/         # Fonts & assets
```

## Design System

Zeno uses a comprehensive design system with:
- **Tokens**: Typography, colors, spacing
- **Components**: Reusable UI components (buttons, views)
- **Semantics**: Theme-aware semantic tokens

## Getting Started

1. Clone the repository
2. Open `Zeno.xcodeproj` in Xcode
3. Build and run on a physical iOS device (required for HealthKit & FamilyControls)

## Requirements

- iOS 17.0+
- Physical device (HealthKit & Screen Time features require real hardware)
- Xcode 15.0+

## License

Private project - All rights reserved

