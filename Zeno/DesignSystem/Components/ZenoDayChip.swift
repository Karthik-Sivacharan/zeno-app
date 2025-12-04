import SwiftUI

/// A selectable chip for day-of-week selection.
/// Used in the blocking schedule configuration.
///
/// The chip has two states:
/// - **Selected**: Primary accent background with visible border
/// - **Unselected**: Subtle card background with muted border
struct DayChip: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void
    
    /// Square-ish proportions for day chips
    private let size: CGFloat = 44
    
    var body: some View {
        Button(action: action) {
            Text(day.shortLabel)
                .font(ZenoTokens.Typography.labelMedium)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.fullName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        // No animation - prevents layout glitches when toggling
    }
    
    // MARK: - Computed Styles
    
    private var backgroundColor: Color {
        isSelected
            ? ZenoSemanticTokens.Theme.primary.opacity(0.15)
            : ZenoSemanticTokens.Theme.card
    }
    
    private var foregroundColor: Color {
        isSelected
            ? ZenoSemanticTokens.Theme.primary
            : ZenoSemanticTokens.Theme.mutedForeground
    }
    
    private var borderColor: Color {
        isSelected
            ? ZenoSemanticTokens.Theme.primary
            : ZenoSemanticTokens.Theme.border
    }
    
    private var borderWidth: CGFloat {
        // Keep consistent border width to prevent layout shifts
        ZenoSemanticTokens.Stroke.medium
    }
}

// MARK: - Day Chip Row

/// A horizontal row of all 7 day chips.
/// Displays days in calendar order (Sunday to Saturday).
struct DayChipRow: View {
    @Binding var activeDays: Set<Weekday>
    
    var body: some View {
        HStack(spacing: ZenoSemanticTokens.Space.sm) {
            ForEach(Weekday.allCases) { day in
                DayChip(
                    day: day,
                    isSelected: activeDays.contains(day),
                    action: { toggleDay(day) }
                )
            }
        }
    }
    
    private func toggleDay(_ day: Weekday) {
        // Don't allow removing the last day
        if activeDays.contains(day) {
            if activeDays.count > 1 {
                activeDays.remove(day)
            }
        } else {
            activeDays.insert(day)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: ZenoSemanticTokens.Space.lg) {
        // Individual chips
        HStack(spacing: ZenoSemanticTokens.Space.sm) {
            DayChip(day: .monday, isSelected: true) {}
            DayChip(day: .tuesday, isSelected: false) {}
            DayChip(day: .wednesday, isSelected: true) {}
        }
        
        // Full row
        DayChipRow(activeDays: .constant(Set(Weekday.allCases)))
        
        // Partial selection
        DayChipRow(activeDays: .constant([.monday, .tuesday, .wednesday, .thursday, .friday]))
    }
    .padding()
    .background(ZenoSemanticTokens.Theme.background)
}

