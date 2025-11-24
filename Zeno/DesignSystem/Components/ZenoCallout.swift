import SwiftUI

enum ZenoCalloutVariant {
    case info
    case success
    case warning
    case error
}

struct ZenoCallout: View {
    let icon: String
    let text: String
    let variant: ZenoCalloutVariant
    
    init(icon: String, text: String, variant: ZenoCalloutVariant = .info) {
        self.icon = icon
        self.text = text
        self.variant = variant
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: ZenoSemanticTokens.Space.md) {
            Image(systemName: icon)
                .font(ZenoTokens.Typography.titleXSmall)
                .foregroundColor(iconColor)
            
            Text(text)
                .font(ZenoTokens.Typography.bodySmall)
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(ZenoSemanticTokens.Space.md)
        .background(backgroundColor)
        .cornerRadius(ZenoSemanticTokens.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                .stroke(borderColor, lineWidth: ZenoSemanticTokens.Stroke.thin)
        )
    }
    
    private var iconColor: Color {
        switch variant {
        case .info: return ZenoTokens.ColorBase.Sand._50
        case .success: return ZenoTokens.ColorBase.Acid._500
        case .warning: return ZenoTokens.ColorBase.Ember._500
        case .error: return ZenoTokens.ColorBase.Clay._400
        }
    }
    
    private var textColor: Color {
        switch variant {
        case .info: return ZenoTokens.ColorBase.Sand._50
        case .success: return ZenoTokens.ColorBase.Acid._300
        case .warning: return ZenoTokens.ColorBase.Ember._300
        case .error: return ZenoTokens.ColorBase.Clay._300
        }
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .info: return ZenoSemanticTokens.Theme.card
        case .success: return ZenoTokens.ColorBase.Acid._900.opacity(ZenoTokens.OpacityLevel._25)
        case .warning: return ZenoTokens.ColorBase.Ember._900.opacity(ZenoTokens.OpacityLevel._50)
        case .error: return ZenoSemanticTokens.Theme.destructive.opacity(ZenoTokens.OpacityLevel._25)
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .info: return ZenoSemanticTokens.Theme.border
        case .success: return ZenoTokens.ColorBase.Acid._700.opacity(ZenoTokens.OpacityLevel._50)
        case .warning: return ZenoTokens.ColorBase.Ember._700.opacity(ZenoTokens.OpacityLevel._50)
        case .error: return ZenoSemanticTokens.Theme.destructive.opacity(ZenoTokens.OpacityLevel._50)
        }
    }
}

#Preview {
    VStack {
        ZenoCallout(icon: "info.circle", text: "This is an info callout.", variant: .info)
        ZenoCallout(icon: "checkmark.circle.fill", text: "Action successful.", variant: .success)
        ZenoCallout(icon: "exclamationmark.triangle", text: "Warning: This action is permanent.", variant: .warning)
        ZenoCallout(icon: "xmark.octagon", text: "Error: Connection failed.", variant: .error)
    }
    .padding()
    .background(ZenoSemanticTokens.Theme.background)
}

