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
    
    /// Steps that have been "used" (spent as credits)
    private var stepsUsed: Int {
        max(stepsWalked - stepsAvailable, 0)
    }
    
    /// Time that has been spent
    private var timeSpent: Int {
        max(timeEarned - timeAvailable, 0)
    }
    
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
    
    /// Left stat (used)
    private var usedValue: String {
        switch displayMode {
        case .steps:
            return formatNumber(stepsUsed)
        case .time:
            return "\(timeSpent)"
        }
    }
    
    /// Left stat label
    private var usedLabel: String {
        switch displayMode {
        case .steps:
            return "used"
        case .time:
            return "min used"
        }
    }
    
    /// Right stat (available)
    private var availableValue: String {
        switch displayMode {
        case .steps:
            return formatNumber(stepsAvailable)
        case .time:
            return "\(timeAvailable)"
        }
    }
    
    /// Right stat label
    private var availableLabel: String {
        switch displayMode {
        case .steps:
            return "left"
        case .time:
            return "min left"
        }
    }
    
    /// Left icon
    private var usedIcon: String {
        switch displayMode {
        case .steps:
            return "figure.walk"
        case .time:
            return "clock"
        }
    }
    
    /// Right icon
    private var availableIcon: String {
        "lock.open"
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: ZenoSemanticTokens.Space.md) {
            // MARK: - Header with Toggle
            headerSection
            
            // MARK: - Hero Number
            heroSection
            
            // MARK: - Gauge Bar
            ZenoGaugeBar(progress: progress)
                .padding(.top, ZenoSemanticTokens.Space.xs)
            
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
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .animation(.easeOut(duration: ZenoSemanticTokens.Motion.Duration.snap), value: displayMode)
            }
        }
        .padding(ZenoTokens.SpacingScale._1)
        .background(
            Capsule()
                .fill(ZenoSemanticTokens.Theme.card)
                .overlay(
                    Capsule()
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
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack {
            // Left: Used (icon + value + label inline)
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                Image(systemName: usedIcon)
                    .font(.system(size: ZenoSemanticTokens.Size.iconSmall))
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                
                Text(usedValue)
                    .font(ZenoTokens.Typography.monoMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .contentTransition(.numericText())
                
                Text(usedLabel)
                    .font(ZenoTokens.Typography.labelSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            
            Spacer()
            
            // Right: Available (value + label + icon inline)
            HStack(spacing: ZenoSemanticTokens.Space.xs) {
                Text(availableValue)
                    .font(ZenoTokens.Typography.monoMedium)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                    .contentTransition(.numericText())
                
                Text(availableLabel)
                    .font(ZenoTokens.Typography.labelSmall)
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                
                Image(systemName: availableIcon)
                    .font(.system(size: ZenoSemanticTokens.Size.iconSmall))
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
            }
        }
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
