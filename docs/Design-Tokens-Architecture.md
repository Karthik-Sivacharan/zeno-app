## Zeno Design Tokens – Architecture (Brand-Agnostic)

This document defines how we structure and name design tokens for Zeno. Concrete values will come from the brand identity later.

### 1. Token Layers

- **Global tokens**: Core primitives that rarely change (for example, spacing scale, radius scale, typography scale).
- **Semantic tokens**: Map primitives to meanings in the Zeno UI (for example, surface backgrounds, primary/secondary text, success/warning states).
- **Component implementation**: Reusable components (for example, primary button, card) map their internal states directly to **Semantic tokens**. We do *not* have a dedicated "Component tokens" layer.

Tokens should be applied in this order inside the UI:

`Component logic → Semantic tokens → Global primitives`

### 2. Global Token Categories (Tailwind v4–Aligned)

Global tokens are implemented in Swift as `ZenoTokens` and mirror Tailwind CSS v4 scales where it makes sense for iOS.

#### 2.1 Color (Primitive)

Primitive color tokens live in `ZenoTokens.ColorBase`:

- Neutral "Swamp" ramp (backgrounds/dividers):
  - `ColorBase.Swamp._50` ... `_950`
- Surface "Moss" ramp (surfaces/cards):
  - `ColorBase.Moss._50` ... `_950`
- Text "Sand" ramp (typography/icons):
  - `ColorBase.Sand._50` ... `_950`
- Brand "Volt" ramp (accent/success):
  - `ColorBase.Volt._50` ... `_950`
- Error "Clay" ramp (error/locked):
  - `ColorBase.Clay._50` ... `_950`
- Warning "Ember" ramp (warning/time running out):
  - `ColorBase.Ember._50` ... `_950`

#### 2.2 Typography (Scale)

Typography uses specific naming conventions for hierarchy.

- **Display**: `displayLarge` (96pt), `displayMedium` (52pt), `displaySmall` (44pt), `displayXSmall` (36pt).
- **Title**: `titleLarge` (40pt), `titleMedium` (32pt), `titleSmall` (24pt), `titleXSmall` (20pt), `titleXXSmall` (16pt).
- **Label**: `labelLarge` (18pt) ... `labelXSmall` (12pt).
- **Body**: `bodyLarge` (18pt) ... `bodyXSmall` (12pt).
- **Mono**: `monoLarge` (18pt), `monoMedium` (16pt), `monoSmall` (14pt).

All fonts are accessed via `ZenoTokens.Typography.*`.

#### 2.3 Spacing

Spacing is Tailwind v4–inspired, with a numeric primitive scale and a smaller semantic set:

- Primitive scale (`SpacingScale`):
  - `_0_5`, `_1` ... `_96`
- Semantic spacing (`Space`):
  - `Space.xs`, `Space.sm`, `Space.md`, `Space.lg`, `Space.xl`, `Space.xxl`.

#### 2.4 Radius

Radius tokens follow Tailwind's rounded scale:

- Primitive radius (`CornerRadiusScale`):
  - `none`, `sm`, `default`, `md`, `lg`, `xl`, `2xl`, `3xl`, `full`
- Semantic radius (`Radius`):
  - `Radius.none`, `Radius.sm` ... `Radius.pill`.

#### 2.5 Blur

Blur tokens for glassmorphism and layering:

- Semantic Blur (`Blur`):
  - `none`, `backgroundSoft`, `backgroundStrong`, `overlay`.
  - `progressiveStep1`, `progressiveStep2`.
- Layer Blur (`LayerBlur`):
  - `sm`, `md`, `lg`, `xl`.

#### 2.6 Shadows and Opacity

- **Shadows**: `Shadow.none`, `Shadow.card`, `Shadow.elevated`, `Shadow.overlay`.
- **Opacity**: `Opacity.disabled`, `Opacity.muted`, `Opacity.overlay`, `Opacity.full`.

### 3. Semantic Tokens Usage (The 3rd Layer)

We do not define specific `ButtonPrimary` or `CardBase` tokens in the design system file. Instead, reusable components should define their own styles using **Semantic Tokens** (or `ColorBase` aliases that act as semantics).

**Example Mapping strategy:**

*   **Primary Button**:
    *   Background: `ColorBase.brand500` (Volt)
    *   Text: `ColorBase.Sand._50`
*   **Card**:
    *   Background: `ColorBase.Moss._900`
    *   Border: `ColorBase.neutral100`
*   **Success State**:
    *   Background: `ColorBase.positive500` (with opacity)
    *   Text: `ColorBase.positive500`

### 4. Usage Guidelines

- **Token-first**:
  - All colors, typography, spacing, radii, shadows, and sizing MUST use design tokens.
  - Do not hard-code raw numbers or hex codes in views.
- **Component Construction**:
  - Build components by composing Semantic tokens.
  - Example: `padding(ZenoTokens.Space.md)` instead of `padding(16)`.
- **Brand Integration**:
  - The `ColorBase` enums act as the palette. Changing these values updates the entire app's theme.

