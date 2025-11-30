import SwiftUI
import Foundation

/// Primitive design tokens for Zeno.
///
/// These are the raw building blocks: scales, base colors, typography sizes.
/// They have no semantic meaning on their own - they are combined in Semantics
/// to create meaningful, contextual design decisions.
extension Color {
    /// Create a Color from a hex string like "#AABBCC" or "AABBCC".
    /// This keeps brand colors close to their original design spec.
    static func fromHex(_ hex: String) -> Color {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed

        guard hexString.count == 6, let rgb = UInt32(hexString, radix: 16) else {
            return Color.clear
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        return Color(red: r, green: g, blue: b)
    }
}

enum ZenoTokens {
    // MARK: - Typography (Uber Base System)
    // https://base.uber.com/6d2425e9f/p/976582-typography/b/13e172
    
    enum Typography {
        enum Size {
            static let displayLarge: CGFloat = 96
            static let displayMedium: CGFloat = 52
            static let displaySmall: CGFloat = 44
            static let displayXSmall: CGFloat = 32
            
            static let titleLarge: CGFloat = 40
            static let titleMedium: CGFloat = 32
            static let titleSmall: CGFloat = 24
            static let titleXSmall: CGFloat = 20
            static let titleXXSmall: CGFloat = 16
            
            static let labelLarge: CGFloat = 18
            static let labelMedium: CGFloat = 16
            static let labelSmall: CGFloat = 14
            static let labelXSmall: CGFloat = 12
            
            static let bodyLarge: CGFloat = 18
            static let bodyMedium: CGFloat = 16
            static let bodySmall: CGFloat = 14
            static let bodyXSmall: CGFloat = 12
            
            static let monoLarge: CGFloat = 18
            static let monoMedium: CGFloat = 16
            static let monoSmall: CGFloat = 14
        }

        // MARK: Display
        // Uses Syne-ExtraBold
        
        static var displayLarge: Font { .custom("Syne-ExtraBold", size: Size.displayLarge) }
        static var displayMedium: Font { .custom("Syne-ExtraBold", size: Size.displayMedium) }
        static var displaySmall: Font { .custom("Syne-ExtraBold", size: Size.displaySmall) }
        static var displayXSmall: Font { .custom("Syne-ExtraBold", size: Size.displayXSmall) }

        // MARK: Title
        // Uses SpaceGrotesk-Medium (Updated from Regular)
        
        static var titleLarge: Font { .custom("SpaceGrotesk-Medium", size: Size.titleLarge) }
        static var titleMedium: Font { .custom("SpaceGrotesk-Medium", size: Size.titleMedium) }
        static var titleSmall: Font { .custom("SpaceGrotesk-Medium", size: Size.titleSmall) }
        static var titleXSmall: Font { .custom("SpaceGrotesk-Medium", size: Size.titleXSmall) }
        static var titleXXSmall: Font { .custom("SpaceGrotesk-Medium", size: Size.titleXXSmall) }

        // MARK: Label
        // Uses SpaceGrotesk-Regular
        
        static var labelLarge: Font { .custom("SpaceGrotesk-Regular", size: Size.labelLarge) }
        static var labelMedium: Font { .custom("SpaceGrotesk-Regular", size: Size.labelMedium) }
        static var labelSmall: Font { .custom("SpaceGrotesk-Regular", size: Size.labelSmall) }
        static var labelXSmall: Font { .custom("SpaceGrotesk-Regular", size: Size.labelXSmall) }

        // MARK: Body
        // Uses SpaceGrotesk-Regular
        
        static var bodyLarge: Font { .custom("SpaceGrotesk-Regular", size: Size.bodyLarge) }
        static var bodyMedium: Font { .custom("SpaceGrotesk-Regular", size: Size.bodyMedium) }
        static var bodySmall: Font { .custom("SpaceGrotesk-Regular", size: Size.bodySmall) }
        static var bodyXSmall: Font { .custom("SpaceGrotesk-Regular", size: Size.bodyXSmall) }

        // MARK: Mono
        // Uses SpaceMono-Medium
        
        static var monoLarge: Font { .custom("SpaceMono-Medium", size: Size.monoLarge) }
        static var monoMedium: Font { .custom("SpaceMono-Medium", size: Size.monoMedium) }
        static var monoSmall: Font { .custom("SpaceMono-Medium", size: Size.monoSmall) }
        
        // MARK: Mono Display (For large numeric displays like steps)
        // Uses SpaceMono-Bold for emphasis at display sizes
        
        static var monoDisplayXLarge: Font { .custom("SpaceMono-Bold", size: Size.displayMedium) } // 52pt
        static var monoDisplayLarge: Font { .custom("SpaceMono-Bold", size: Size.displaySmall) }  // 44pt
        static var monoDisplayMedium: Font { .custom("SpaceMono-Bold", size: Size.titleLarge) }   // 40pt
    }

    // MARK: - Primitive Scales (Spacing, Radius, etc.)

    enum SpacingScale {
        // Spacing scale, assuming 1rem = 16pt so each unit = 4pt.
        static let _0_5: CGFloat = 2      // 0.125rem
        static let _1: CGFloat = 4        // 0.25rem
        static let _1_5: CGFloat = 6      // 0.375rem
        static let _2: CGFloat = 8        // 0.5rem
        static let _2_5: CGFloat = 10     // 0.625rem
        static let _3: CGFloat = 12       // 0.75rem
        static let _3_5: CGFloat = 14     // 0.875rem
        static let _4: CGFloat = 16       // 1rem
        static let _5: CGFloat = 20       // 1.25rem
        static let _6: CGFloat = 24       // 1.5rem
        static let _7: CGFloat = 28       // 1.75rem
        static let _8: CGFloat = 32       // 2rem
        static let _9: CGFloat = 36       // 2.25rem
        static let _10: CGFloat = 40      // 2.5rem
        static let _11: CGFloat = 44      // 2.75rem
        static let _12: CGFloat = 48      // 3rem
        static let _14: CGFloat = 56      // 3.5rem
        static let _16: CGFloat = 64      // 4rem
        static let _20: CGFloat = 80      // 5rem
        static let _24: CGFloat = 96      // 6rem
        static let _28: CGFloat = 112     // 7rem
        static let _32: CGFloat = 128     // 8rem
        static let _36: CGFloat = 144     // 9rem
        static let _40: CGFloat = 160     // 10rem
        static let _44: CGFloat = 176     // 11rem
        static let _48: CGFloat = 192     // 12rem
        static let _52: CGFloat = 208     // 13rem
        static let _56: CGFloat = 224     // 14rem
        static let _60: CGFloat = 240     // 15rem
        static let _64: CGFloat = 256     // 16rem
        static let _72: CGFloat = 288     // 18rem
        static let _80: CGFloat = 320     // 20rem
        static let _96: CGFloat = 384     // 24rem
    }

    enum CornerRadiusScale {
        // Radius scale (approximate rem→pt mapping).
        static let none: CGFloat = 0
        static let sm: CGFloat = 2        // 0.125rem
        static let `default`: CGFloat = 4 // 0.25rem
        static let md: CGFloat = 6        // 0.375rem
        static let lg: CGFloat = 8        // 0.5rem
        static let xl: CGFloat = 12       // 0.75rem
        static let _2xl: CGFloat = 16     // 1rem
        static let _3xl: CGFloat = 24     // 1.5rem
        static let full: CGFloat = .infinity
    }

    /// SwiftUI representation of a Tailwind-like shadow preset.
    struct ShadowSpec {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    /// SwiftUI representation of a ring (outline) preset.
    struct RingSpec {
        let color: Color
        let lineWidth: CGFloat
    }

    enum BlurRadiusScale {
        // Blur radius scale, mapped to points (roughly px-equivalent).
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let _2xl: CGFloat = 24
        static let _3xl: CGFloat = 32
    }

    enum ShadowLevel {
        // Shadow presets for iOS.
        static let sm = ShadowSpec(
            color: Color.black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 2
        )

        static let `default` = ShadowSpec(
            color: Color.black.opacity(0.08),
            radius: 6,
            x: 0,
            y: 4
        )

        static let md = ShadowSpec(
            color: Color.black.opacity(0.1),
            radius: 10,
            x: 0,
            y: 6
        )

        static let lg = ShadowSpec(
            color: Color.black.opacity(0.12),
            radius: 16,
            x: 0,
            y: 10
        )

        static let xl = ShadowSpec(
            color: Color.black.opacity(0.16),
            radius: 24,
            x: 0,
            y: 18
        )

        static let _2xl = ShadowSpec(
            color: Color.black.opacity(0.2),
            radius: 32,
            x: 0,
            y: 24
        )
    }

    enum RingWidth {
        // Ring widths; color is provided by semantic tokens.
        static let _1: CGFloat = 1
        static let _2: CGFloat = 2
        static let _4: CGFloat = 4
    }

    enum OpacityLevel {
        // Common opacity presets.
        static let _5: Double = 0.05
        static let _10: Double = 0.1
        static let _25: Double = 0.25
        static let _40: Double = 0.4
        static let _50: Double = 0.5
        static let _60: Double = 0.6
        static let _75: Double = 0.75
        static let _90: Double = 0.9
        static let _100: Double = 1.0
    }

    // MARK: - Color Tokens (Brand Palette)
    enum ColorBase {

        // MARK: 1. PRIMARY: OLIVE (The Foundation)
        // Based on "Feldgrau/Artichoke".
        // 900/950 are your "Dark Mode" backgrounds.
        enum Olive {
            static let _50  = Color.fromHex("#F4F6F3")
            static let _100 = Color.fromHex("#E6EBE6")
            static let _200 = Color.fromHex("#C8D4C9")
            static let _300 = Color.fromHex("#A3B5A6")
            static let _400 = Color.fromHex("#7F9684")
            static let _500 = Color.fromHex("#5E7564") // Base Brand Color
            static let _600 = Color.fromHex("#495C4E")
            static let _700 = Color.fromHex("#354239")
            static let _800 = Color.fromHex("#232B25")
            static let _900 = Color.fromHex("#141C18") // MAIN APP BG (Deep Charcoal Green)
            static let _950 = Color.fromHex("#0A0F0D") // Darkest Depth
        }

        // MARK: 2. ACCENT A: SAND (The Light/Text)
        // Based on "Dark Vanilla". Used for Text & Borders.
        enum Sand {
            static let _50  = Color.fromHex("#FAF9F5")
            static let _100 = Color.fromHex("#F2EFE8")
            static let _200 = Color.fromHex("#E6DEC9")
            static let _300 = Color.fromHex("#D8BF9B") // Base Accent (Headers)
            static let _400 = Color.fromHex("#BF9F7A")
            static let _500 = Color.fromHex("#A6825B")
            static let _600 = Color.fromHex("#8C6843")
            static let _700 = Color.fromHex("#735233")
            static let _800 = Color.fromHex("#593E26")
            static let _900 = Color.fromHex("#402B19")
            static let _950 = Color.fromHex("#26190E")
        }

        // MARK: 3. ACCENT B: BRASS (The Highlight)
        // Based on "Brass". Used for Premium/Active states.
        enum Brass {
            static let _50  = Color.fromHex("#FBF8F2")
            static let _100 = Color.fromHex("#F5EFDE")
            static let _200 = Color.fromHex("#E9DBB6")
            static let _300 = Color.fromHex("#DCC68D")
            static let _400 = Color.fromHex("#B4913E") // Base Brass
            static let _500 = Color.fromHex("#96782E")
            static let _600 = Color.fromHex("#7A6123")
            static let _700 = Color.fromHex("#614C1A")
            static let _800 = Color.fromHex("#473712")
            static let _900 = Color.fromHex("#2E230B")
            static let _950 = Color.fromHex("#171105")
        }

        // MARK: 4. FUNCTIONAL COLORS

        // SUCCESS: ACID (Hyper-saturated Olive/Yellow)
        enum Acid {
            static let _50  = Color.fromHex("#F7FDE8")
            static let _100 = Color.fromHex("#ECFAC6")
            static let _200 = Color.fromHex("#D9F58D")
            static let _300 = Color.fromHex("#BFED55")
            static let _400 = Color.fromHex("#CCFF00") // Neon/Cyber Success
            static let _500 = Color.fromHex("#8CB300")
            static let _600 = Color.fromHex("#668000")
            static let _700 = Color.fromHex("#465900")
            static let _800 = Color.fromHex("#293300")
            static let _900 = Color.fromHex("#141A00")
            static let _950 = Color.fromHex("#080A00")
        }

        // DANGER: CLAY (Earthy Red/Brown) - Based on "Coconut"
        enum Clay {
            static let _50  = Color.fromHex("#FCF5F4")
            static let _100 = Color.fromHex("#F8E8E6")
            static let _200 = Color.fromHex("#EFCEC9")
            static let _300 = Color.fromHex("#E3B0A8")
            static let _400 = Color.fromHex("#D18C82")
            static let _500 = Color.fromHex("#965846") // Base Clay
            static let _600 = Color.fromHex("#7D4233")
            static let _700 = Color.fromHex("#633125")
            static let _800 = Color.fromHex("#4A2219")
            static let _900 = Color.fromHex("#30140F")
            static let _950 = Color.fromHex("#1A0A07")
        }

        // WARNING: EMBER (Burnt Orange)
        enum Ember {
            static let _50  = Color.fromHex("#FEF8F2")
            static let _100 = Color.fromHex("#FCECD9")
            static let _200 = Color.fromHex("#F8D5AC")
            static let _300 = Color.fromHex("#F2BD7E")
            static let _400 = Color.fromHex("#EA9F52")
            static let _500 = Color.fromHex("#B8853E") // Base Ember
            static let _600 = Color.fromHex("#96632B")
            static let _700 = Color.fromHex("#75491D")
            static let _800 = Color.fromHex("#543312")
            static let _900 = Color.fromHex("#36200A")
            static let _950 = Color.fromHex("#1F1105")
        }

        // INFO: SILT (Blue-Grey/Teal)
        enum Silt {
            static let _50  = Color.fromHex("#F2F7F8")
            static let _100 = Color.fromHex("#E1EBED")
            static let _200 = Color.fromHex("#C2D6DB")
            static let _300 = Color.fromHex("#9FBEC6")
            static let _400 = Color.fromHex("#7DA4AD")
            static let _500 = Color.fromHex("#5D8691") // Base Silt
            static let _600 = Color.fromHex("#46666F")
            static let _700 = Color.fromHex("#324B52")
            static let _800 = Color.fromHex("#213238")
            static let _900 = Color.fromHex("#121D21")
            static let _950 = Color.fromHex("#080F12")
        }

        // MARK: 5. GRAYS (The Structure)

        // TINTED GRAY: MOSS (Warm/Greenish Gray)
        // Use for Cards/Surfaces to blend with Olive.
        enum Moss {
            static let _50  = Color.fromHex("#F6F7F6")
            static let _100 = Color.fromHex("#EBEDEC")
            static let _200 = Color.fromHex("#D6D9D7")
            static let _300 = Color.fromHex("#B3B8B5")
            static let _400 = Color.fromHex("#8A918D")
            static let _500 = Color.fromHex("#69706C")
            static let _600 = Color.fromHex("#4F5451")
            static let _700 = Color.fromHex("#393D3B")
            static let _800 = Color.fromHex("#252927")
            static let _900 = Color.fromHex("#161A18")
            static let _950 = Color.fromHex("#0B0D0C")
        }

        // NEUTRAL GRAY: STONE (Pure/Cold Gray)
        // Use for inactive text or deep shadows.
        enum Stone {
            static let _50  = Color.fromHex("#FAFAFA")
            static let _100 = Color.fromHex("#F5F5F5")
            static let _200 = Color.fromHex("#E5E5E5")
            static let _300 = Color.fromHex("#D4D4D4")
            static let _400 = Color.fromHex("#A3A3A3")
            static let _500 = Color.fromHex("#737373")
            static let _600 = Color.fromHex("#525252")
            static let _700 = Color.fromHex("#404040")
            static let _800 = Color.fromHex("#262626")
            static let _900 = Color.fromHex("#171717")
            static let _950 = Color.fromHex("#0A0A0A")
        }

        // MARK: 6. UTILITIES (Black & White)
        enum Black {
            static let _100 = Color.black.opacity(1.0)
            static let _90  = Color.black.opacity(0.9)
            static let _75  = Color.black.opacity(0.75)
            static let _50  = Color.black.opacity(0.5)
            static let _25  = Color.black.opacity(0.25)
            static let _10  = Color.black.opacity(0.1)
            static let _5   = Color.black.opacity(0.05)
        }

        enum White {
            static let _100 = Color.white.opacity(1.0)
            static let _90  = Color.white.opacity(0.9)
            static let _75  = Color.white.opacity(0.75)
            static let _50  = Color.white.opacity(0.5)
            static let _25  = Color.white.opacity(0.25)
            static let _10  = Color.white.opacity(0.1)
            static let _5   = Color.white.opacity(0.05)
        }
    }
}

