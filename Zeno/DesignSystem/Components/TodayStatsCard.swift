import SwiftUI

/// Display mode for the TodayStatsCard
enum StatsDisplayMode: String, CaseIterable {
    case steps = "Steps"
    case time = "Time"
}

/// A dashboard card showing today's activity stats with a Steps/Time toggle.
/// Displays a hero number, progress gauge, and supporting stats.
///
/// **Steps Mode:** Shows steps walked today and steps left to use
/// **Time Mode:** Shows time earned today and time left to use
struct TodayStatsCard: View {
    // MARK: - Data Inputs
    
    /// Total steps walked today
    let stepsWalked: Int
    
    /// Steps available to use (for unlocking)
    let stepsAvailable: Int
    
    /// Total time (minutes) earned today
    let timeEarned: Int
    
    /// Time (minutes) available to use
    let timeAvailable: Int
    
    // MARK: - State
    
    @State private var displayMode: StatsDisplayMode = .steps
    
    // MARK: - Computed Properties
    
    /// Progress for the gauge bar (available / total)
    private var progress: CGFloat {
        switch displayMode {
        case .steps:
            guard stepsWalked > 0 else { return 0 }
            return CGFloat(stepsAvailable) / CGFloat(stepsWalked)
        case .time:
            guard timeEarned > 0 else { return 0 }
            return CGFloat(timeAvailable) / CGFloat(timeEarned)
        }
    }
    
    /// Formatted hero number
    private var heroValue: String {
        switch displayMode {
        case .steps:
            return formatNumber(stepsWalked)
        case .time:
            return "\(timeEarned)"
        }
    }
    
    /// Hero label
    private var heroLabel: String {
        switch displayMode {
        case .steps:
            return "steps walked"
        case .time:
            return "min earned"
        }
    }
    
    /// Available stat value
    private var availableValue: String {
        switch displayMode {
        case .steps:
            return formatNumber(stepsAvailable)
        case .time:
            return "\(timeAvailable)"
        }
    }
    
    /// Available stat label
    private var availableLabel: String {
        "left to use"
    }
    
    /// Available icon - contextual based on mode
    private var availableIcon: String {
        switch displayMode {
        case .steps:
            return "figure.walk"
        case .time:
            return "hourglass"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.sm) {
            // MARK: - Header with Toggle
            headerSection
            
            // MARK: - Hero Number
            heroSection
            
            // MARK: - Segmented Progress Bar (stagger animates on every toggle)
            ZenoSegmentedBar(progress: progress)
                .id(displayMode) // Force recreate on toggle to replay stagger animation
            
            // MARK: - Stats Row (Icons + Numbers)
            statsRow
        }
        .padding(ZenoSemanticTokens.Space.md)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.xl))
        .animation(.smooth(duration: ZenoSemanticTokens.Motion.Duration.fast), value: displayMode)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            Text("Today")
                .font(ZenoTokens.Typography.titleXSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
            
            Spacer()
            
            // Segmented Toggle
            modeToggle
        }
    }
    
    // MARK: - Mode Toggle (Steps | Time)
    
    /// Corner radius for toggle - mechanical, not pill-shaped
    private let toggleRadius = ZenoSemanticTokens.Radius.md
    
    private var modeToggle: some View {
        HStack(spacing: 0) {
            ForEach(StatsDisplayMode.allCases, id: \.self) { mode in
                Button {
                    displayMode = mode
                } label: {
                    Text(mode.rawValue)
                        .font(ZenoTokens.Typography.labelMedium)
                        .foregroundColor(toggleForeground(for: mode))
                        .padding(.horizontal, ZenoSemanticTokens.Space.md)
                        .padding(.vertical, ZenoSemanticTokens.Space.sm)
                        .background(toggleBackground(for: mode))
                        .clipShape(RoundedRectangle(cornerRadius: toggleRadius))
                }
                .buttonStyle(.plain)
                .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap), value: displayMode)
            }
        }
        .padding(ZenoTokens.SpacingScale._1)
        .background(
            RoundedRectangle(cornerRadius: toggleRadius + ZenoTokens.SpacingScale._1)
                .fill(ZenoSemanticTokens.Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: toggleRadius + ZenoTokens.SpacingScale._1)
                        .strokeBorder(ZenoSemanticTokens.Theme.border, lineWidth: ZenoSemanticTokens.Stroke.hairline)
                )
        )
    }
    
    private func toggleBackground(for mode: StatsDisplayMode) -> Color {
        displayMode == mode ? ZenoSemanticTokens.Theme.primary : .clear
    }
    
    private func toggleForeground(for mode: StatsDisplayMode) -> Color {
        // Active: dark text on bright primary background (high contrast)
        // Inactive: foreground text on transparent (readable)
        displayMode == mode ? ZenoSemanticTokens.Theme.primaryForeground : ZenoSemanticTokens.Theme.foreground
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: ZenoSemanticTokens.Space.xs) {
            // Big number (52pt mono bold)
            Text(heroValue)
                .font(ZenoTokens.Typography.monoDisplayXLarge)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                .contentTransition(.numericText())
            
            // Label
            Text(heroLabel)
                .font(ZenoTokens.Typography.labelMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Stats Row (Available Only)
    
    private var statsRow: some View {
        HStack(spacing: ZenoSemanticTokens.Space.xxs) {
            // ZenoIcon ensures consistent sizing across different SF Symbols
            ZenoIcon(availableIcon, size: .medium, color: ZenoSemanticTokens.Theme.primary)
            
            Text(availableValue)
                .font(ZenoTokens.Typography.monoMedium)
                .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                .contentTransition(.numericText())
            
            Text(availableLabel)
                .font(ZenoTokens.Typography.labelSmall)
                .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Card Background
    
    private var cardBackground: some View {
        ZenoSemanticTokens.Theme.card
            .overlay(
                RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.xl)
                    .strokeBorder(ZenoSemanticTokens.Theme.border, lineWidth: ZenoSemanticTokens.Stroke.hairline)
            )
    }
    
    // MARK: - Helpers
    
    /// Formats a number with thousands separator (e.g., 12543 → "12,543")
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Preview

#Preview("Today Stats Card - Steps Mode") {
    VStack {
        TodayStatsCard(
            stepsWalked: 12543,
            stepsAvailable: 4500,
            timeEarned: 125,
            timeAvailable: 45
        )
    }
    .padding(ZenoSemanticTokens.Space.md)
    .background(ZenoSemanticTokens.Theme.background)
}

#Preview("Today Stats Card - Zero State") {
    VStack {
        TodayStatsCard(
            stepsWalked: 0,
            stepsAvailable: 0,
            timeEarned: 0,
            timeAvailable: 0
        )
    }
    .padding(ZenoSemanticTokens.Space.md)
    .background(ZenoSemanticTokens.Theme.background)
}

#Preview("Today Stats Card - Full Available") {
    VStack {
        TodayStatsCard(
            stepsWalked: 8000,
            stepsAvailable: 8000,
            timeEarned: 80,
            timeAvailable: 80
        )
    }
    .padding(ZenoSemanticTokens.Space.md)
    .background(ZenoSemanticTokens.Theme.background)
}

