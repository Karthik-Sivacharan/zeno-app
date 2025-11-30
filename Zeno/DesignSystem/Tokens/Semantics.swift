import SwiftUI

/// Semantic design tokens for Zeno.
///
/// These tokens map primitive values to meaningful, contextual usage.
/// They provide the "why" behind design decisions, not just the "what".
enum ZenoSemanticTokens {
    
    // MARK: - THEME TOKENS (Tailwind v4 Mapping)
    // The "Zeno" implementation of the standard Tailwind slots.
    
    enum Theme {
        
        // MARK: 1. BASE LAYERS
        
        /// Page background.
        /// Zeno: The Deep Swamp.
        static let background = ZenoTokens.ColorBase.Olive._900
        
        /// Default text color.
        /// Zeno: Parchment/Bone (Never pure white).
        static let foreground = ZenoTokens.ColorBase.Sand._300
        
        // MARK: 2. SURFACES (Cards & Popovers)
        
        /// Card background.
        /// Zeno: Moss Glass (Deep transparency).
        static let card = ZenoTokens.ColorBase.Moss._800
        
        /// Text on cards.
        /// Zeno: Standard Bone text.
        static let cardForeground = ZenoTokens.ColorBase.Sand._300
        
        /// Popover/Modal background.
        /// Zeno: Slightly lighter Moss Glass for elevation.
        static let popover = ZenoTokens.ColorBase.Moss._800
        
        /// Text on popovers.
        static let popoverForeground = ZenoTokens.ColorBase.Sand._300
        
        // MARK: 3. BRAND ACTIONS
        
        /// Primary Action (The "Call to Action").
        /// Zeno: Radioactive Acid Green (The Spark).
        static let primary = ZenoTokens.ColorBase.Acid._400
        
        /// Text on Primary Button.
        /// Zeno: Deepest Swamp (for max contrast against Neon).
        static let primaryForeground = ZenoTokens.ColorBase.Olive._950
        
        /// Secondary Action.
        /// Zeno: Mossy Stone (Subtle).
        static let secondary = ZenoTokens.ColorBase.Moss._700
        
        /// Text on Secondary Button.
        /// Zeno: Sand 100 (Bright Bone).
        static let secondaryForeground = ZenoTokens.ColorBase.Sand._100
        
        // MARK: 4. UI STATES
        
        /// Muted backgrounds (Tabs, Disabled states).
        /// Zeno: Dark Swamp mixture.
        static let muted = ZenoTokens.ColorBase.Olive._800
        
        /// Muted text (Subtitles, Placeholders).
        /// Zeno: Mossy Gray.
        static let mutedForeground = ZenoTokens.ColorBase.Moss._400
        
        /// Accent backgrounds (Hover states, List selections).
        /// Zeno: Brass (The "Ancient Gold" highlight).
        static let accent = ZenoTokens.ColorBase.Brass._500.opacity(0.2)
        
        /// Text on Accent backgrounds.
        /// Zeno: Brass 300 (Gold text).
        static let accentForeground = ZenoTokens.ColorBase.Brass._300
        
        // MARK: 5. FEEDBACK
        
        /// Destructive/Error actions.
        /// Zeno: Clay/Terracotta.
        static let destructive = ZenoTokens.ColorBase.Clay._500
        
        /// Text on Destructive backgrounds.
        /// Zeno: White (for safety legibility).
        static let destructiveForeground = ZenoTokens.ColorBase.White._100
        
        // MARK: 6. FORMS & STRUCTURE
        
        /// Borders and Dividers.
        /// Zeno: Moss 600 (Subtle glass edge).
        static let border = ZenoTokens.ColorBase.Moss._600.opacity(0.3)
        
        /// Form Inputs.
        /// Zeno: Deepest Moss.
        static let input = ZenoTokens.ColorBase.Moss._900
        
        /// Focus Rings.
        /// Zeno: Acid Green Glow.
        static let ring = ZenoTokens.ColorBase.Acid._400
        
        // MARK: 7. DATA VISUALIZATION (Charts)
        
        /// Chart 1 (Primary Data): Acid (Green)
        static let chart1 = ZenoTokens.ColorBase.Acid._400
        
        /// Chart 2 (Secondary Data): Silt (Teal/Blue)
        static let chart2 = ZenoTokens.ColorBase.Silt._500
        
        /// Chart 3 (Tertiary Data): Brass (Gold)
        static let chart3 = ZenoTokens.ColorBase.Brass._400
        
        /// Chart 4 (Quaternary Data): Ember (Orange)
        static let chart4 = ZenoTokens.ColorBase.Ember._500
        
        /// Chart 5 (Quinary Data): Clay (Red)
        static let chart5 = ZenoTokens.ColorBase.Clay._500
        
        // MARK: 8. SIDEBAR (Navigation)
        
        /// Sidebar Background.
        /// Zeno: The "Void" (Darker than main background).
        static let sidebar = ZenoTokens.ColorBase.Olive._950
        
        /// Sidebar Text.
        static let sidebarForeground = ZenoTokens.ColorBase.Moss._300
        
        /// Sidebar Active Item BG.
        static let sidebarAccent = ZenoTokens.ColorBase.Moss._800
        
        /// Sidebar Active Item Text.
        static let sidebarAccentForeground = ZenoTokens.ColorBase.Sand._300
        
        /// Sidebar Border/Separator.
        static let sidebarBorder = ZenoTokens.ColorBase.Olive._800
        
        /// Sidebar Focus Ring.
        static let sidebarRing = ZenoTokens.ColorBase.Acid._400
    }
    
    // MARK: - Semantic Spacing
    
    enum Space {
        // General-purpose spacing tokens that wrap the Tailwind scale.
        static let xs: CGFloat = ZenoTokens.SpacingScale._2       // small padding, tight gaps
        static let sm: CGFloat = ZenoTokens.SpacingScale._3
        static let md: CGFloat = ZenoTokens.SpacingScale._4
        static let lg: CGFloat = ZenoTokens.SpacingScale._6
        static let xl: CGFloat = ZenoTokens.SpacingScale._8
        static let xxl: CGFloat = ZenoTokens.SpacingScale._12
    }
    
    // MARK: - Semantic Radius
    
    enum Radius {
        static let none: CGFloat = ZenoTokens.CornerRadiusScale.none
        static let sm: CGFloat = ZenoTokens.CornerRadiusScale.sm
        static let md: CGFloat = ZenoTokens.CornerRadiusScale.md
        static let lg: CGFloat = ZenoTokens.CornerRadiusScale.lg
        static let xl: CGFloat = ZenoTokens.CornerRadiusScale.xl
        static let pill: CGFloat = ZenoTokens.CornerRadiusScale.full
    }
    
    // MARK: - Semantic Blur
    
    enum Blur {
        // Semantic blur usage built on BlurRadiusScale.
        static let none: CGFloat = ZenoTokens.BlurRadiusScale.none
        static let backgroundSoft: CGFloat = ZenoTokens.BlurRadiusScale.sm
        static let backgroundStrong: CGFloat = ZenoTokens.BlurRadiusScale.lg
        static let overlay: CGFloat = ZenoTokens.BlurRadiusScale._2xl
        
        // Progressive blur steps
        static let progressiveStep1: CGFloat = ZenoTokens.BlurRadiusScale.sm
        static let progressiveStep2: CGFloat = ZenoTokens.BlurRadiusScale.xl
    }
    
    enum LayerBlur {
        static let sm: CGFloat = ZenoTokens.BlurRadiusScale.sm
        static let md: CGFloat = ZenoTokens.BlurRadiusScale.md
        static let lg: CGFloat = ZenoTokens.BlurRadiusScale.lg
        static let xl: CGFloat = ZenoTokens.BlurRadiusScale.xl
    }
    
    // MARK: - Semantic Shadows
    
    enum Shadow {
        // Semantic shadows for common use cases.
        static let none = ZenoTokens.ShadowSpec(color: .clear, radius: 0, x: 0, y: 0)
        static let card = ZenoTokens.ShadowLevel.sm
        static let elevated = ZenoTokens.ShadowLevel.lg
        static let overlay = ZenoTokens.ShadowLevel.xl
    }
    
    // MARK: - Semantic Rings
    
    enum Ring {
        // Semantic rings (focus outlines etc.).
        static let focus = ZenoTokens.RingSpec(
            color: ZenoTokens.ColorBase.Olive._500,
            lineWidth: ZenoTokens.RingWidth._2
        )
    }
    
    // MARK: - Semantic Opacity
    
    enum Opacity {
        // Common semantic opacities.
        static let disabled: Double = ZenoTokens.OpacityLevel._40
        static let muted: Double = ZenoTokens.OpacityLevel._60
        static let overlay: Double = ZenoTokens.OpacityLevel._50
        static let full: Double = ZenoTokens.OpacityLevel._100
        /// Subtle background tint (pills, badges)
        static let pillBackground: Double = ZenoTokens.OpacityLevel._10 + 0.05  // 0.15
    }
    
    // MARK: - Semantic Sizes
    
    enum Size {
        /// Progress bar track height
        static let progressBarHeight: CGFloat = ZenoTokens.SpacingScale._2  // 8pt
        /// Status indicator dot
        static let statusDot: CGFloat = ZenoTokens.SpacingScale._2  // 8pt
        /// Standard button height (large CTA)
        static let buttonHeight: CGFloat = ZenoTokens.SpacingScale._14  // 56pt
    }
    
    // MARK: - Motion Tokens (The Physics)
    // Zeno is not "bouncy". It is heavy, deliberate, and smooth.
    // Use clear, linear-out-slow-in timing.
    
    enum Motion {
        enum Duration {
            /// Instant feedback (Button presses) - 0.15s
            static let snap: Double = 0.15
            /// Standard UI transitions (Slide overs) - 0.3s
            static let fast: Double = 0.3
            /// Heavy element movement (Card expansions) - 0.5s
            static let medium: Double = 0.5
            /// The "Zeno" speed (Coin rotation, Unlocking) - 0.8s
            static let slow: Double = 0.8
            /// Atmospheric breathing (Background pulses) - 2.0s
            static let breathe: Double = 2.0
        }
        
        enum Ease {
            /// A heavy mechanical ease. Starts fast, hits a wall, settles.
            static let mechanical = Animation.timingCurve(0.1, 0.9, 0.2, 1.0, duration: Duration.medium)
            /// A smooth, water-like flow.
            static let liquid = Animation.easeInOut(duration: Duration.slow)
            /// Standard UI transition (0.3s easeInOut).
            static let standard = Animation.easeInOut(duration: Duration.fast)
        }
    }
    
    // MARK: - Gradient Tokens (The Atmosphere)
    // The swamp is never flat. Use these for backgrounds and "Glass" fills.
    
    enum Gradients {
        /// The main background: A subtle vignette from Olive 900 to Olive 950.
        static let swampBody = LinearGradient(
            colors: [ZenoTokens.ColorBase.Olive._900, ZenoTokens.ColorBase.Olive._950],
            startPoint: .top,
            endPoint: .bottom
        )
        
        /// The "Void": A deep radial gradient for behind the Zeno Coin.
        static let deepVoid = RadialGradient(
            colors: [ZenoTokens.ColorBase.Olive._800, ZenoTokens.ColorBase.Black._100],
            center: .center,
            startRadius: 0,
            endRadius: 500
        )
        
        /// The "Acid" Strike: Used for the slash or progress fills.
        static let acidFlow = LinearGradient(
            colors: [ZenoTokens.ColorBase.Acid._300, ZenoTokens.ColorBase.Acid._500],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        /// The "Glass" Reflection: Subtle diagonal wash for glass cards.
        static let glassSheen = LinearGradient(
            colors: [ZenoTokens.ColorBase.White._10, ZenoTokens.ColorBase.White._5],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Glow Specs (The Energy)
    // Shadows create depth (darkness). Glows create energy (light).
    // Use these on "Acid" elements and the Zeno eyes.
    
    struct GlowSpec {
        let color: Color
        let radius: CGFloat
    }
    
    enum Glow {
        /// Subtle interface glow for active elements
        static let low = GlowSpec(color: ZenoTokens.ColorBase.Acid._400.opacity(0.3), radius: 8)
        /// Strong neon radiation for the "Unlock" moment
        static let high = GlowSpec(color: ZenoTokens.ColorBase.Acid._400.opacity(0.6), radius: 20)
        /// Warning heat
        static let ember = GlowSpec(color: ZenoTokens.ColorBase.Ember._500.opacity(0.5), radius: 12)
    }
    
    // MARK: - Border/Stroke Tokens (The Structure)
    // Defines the thickness of lines.
    
    enum Stroke {
        /// 0.5pt - Barely visible, used for subtle glass edges
        static let hairline: CGFloat = 0.5
        /// 1pt - Standard UI borders
        static let thin: CGFloat = 1.0
        /// 2pt - Focus rings, button outlines
        static let medium: CGFloat = 2.0
        /// 4pt - The "Slash" or heavy structural dividers
        static let thick: CGFloat = 4.0
    }
    
    // MARK: - Texture Opacity (The Noise)
    // Zeno relies on a "Noise" image overlay. These tokens define how visible that noise is.
    
    enum TextureIntensity {
        /// Barely perceptible grain (Standard BG)
        static let subtle: Double = 0.03
        /// Visible film grain (Cards)
        static let standard: Double = 0.05
        /// Heavy static (Locked/Paralysis state)
        static let heavy: Double = 0.12
    }
}
