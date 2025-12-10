import SwiftUI

/// A standardized section header for consistent typography across the app.
/// Use for uppercase section titles in forms, settings, and content sections.
///
/// Example usage:
/// ```swift
/// ZenoSectionHeader("BLOCKING SCHEDULE")
/// ```
struct ZenoSectionHeader: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(ZenoTokens.Typography.labelSmall)
            .fontWeight(.semibold)
            .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            .tracking(ZenoSemanticTokens.LetterSpacing.extraWide)
    }
}

#Preview {
    ZStack {
        ZenoSemanticTokens.Theme.background.ignoresSafeArea()
        
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xl) {
            ZenoSectionHeader("BLOCKED APPS")
            
            ZenoSectionHeader("BLOCKING SCHEDULE")
            
            ZenoSectionHeader("ACCOUNT")
        }
        .padding()
    }
}


