import SwiftUI

/// A row component for displaying and editing schedule times.
/// Tapping opens a sheet with a time picker (Apple HIG compliant).
///
/// Usage:
/// ```swift
/// ScheduleTimeRow(
///     label: "From",
///     time: $startTime,
///     minimumTime: nil,
///     maximumTime: endTime
/// )
/// ```
struct ScheduleTimeRow: View {
    let label: String
    @Binding var time: Date
    
    /// Optional minimum allowed time (for validation)
    var minimumTime: Date?
    
    /// Optional maximum allowed time (for validation)
    var maximumTime: Date?
    
    /// Whether the time picker sheet is presented
    @State private var isPickerPresented = false
    
    /// Temporary time value while editing (for cancel support)
    @State private var editingTime: Date = Date()
    
    var body: some View {
        Button(action: openPicker) {
            HStack(spacing: ZenoSemanticTokens.Space.md) {
                Text(label)
                    .font(ZenoTokens.Typography.labelLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                
                Spacer()
                
                Text(formattedTime)
                    .font(ZenoTokens.Typography.labelLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.accentForeground)
                
                Image(systemName: "chevron.right")
                    .font(ZenoTokens.Typography.labelSmall.weight(.bold))
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            .padding(ZenoSemanticTokens.Space.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(ZenoSemanticTokens.Theme.card)
        .cornerRadius(ZenoSemanticTokens.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                .stroke(ZenoSemanticTokens.Theme.border, lineWidth: ZenoSemanticTokens.Stroke.thin)
        )
        .sheet(isPresented: $isPickerPresented) {
            TimePickerSheet(
                label: label,
                time: $editingTime,
                minimumTime: minimumTime,
                maximumTime: maximumTime,
                onSave: saveTime,
                onCancel: cancelEdit
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Computed Properties
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    // MARK: - Actions
    
    private func openPicker() {
        // Normalize time to today for consistent picker behavior
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        editingTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? time
        isPickerPresented = true
    }
    
    private func saveTime() {
        time = editingTime
        isPickerPresented = false
    }
    
    private func cancelEdit() {
        isPickerPresented = false
    }
}

// MARK: - Time Picker Sheet

/// A sheet containing the time picker with Cancel/Done buttons.
/// Follows Apple Human Interface Guidelines for modal time selection.
struct TimePickerSheet: View {
    let label: String
    @Binding var time: Date
    var minimumTime: Date?
    var maximumTime: Date?
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZenoSemanticTokens.Theme.background.ignoresSafeArea()
                
                VStack(spacing: ZenoSemanticTokens.Space.lg) {
                    // Title
                    Text("Set \(label) Time")
                        .font(ZenoTokens.Typography.titleSmall)
                        .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                        .padding(.top, ZenoSemanticTokens.Space.lg)
                    
                    Spacer()
                    
                    // Time Picker with range validation
                    DatePicker(
                        "",
                        selection: $time,
                        in: pickerRange,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .colorScheme(.dark)
                    .tint(ZenoSemanticTokens.Theme.primary)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(ZenoSemanticTokens.Theme.primary)
                }
            }
        }
    }
    
    /// Computes the valid date range for the picker.
    /// Normalizes all times to today's date to ensure proper comparison.
    private var pickerRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()
        
        // Default bounds: 12:00 AM to 11:59 PM today
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: today)!
        
        // Normalize minimumTime to today (extract hour/minute, apply to today)
        let normalizedMin: Date
        if let minTime = minimumTime {
            let hour = calendar.component(.hour, from: minTime)
            let minute = calendar.component(.minute, from: minTime)
            normalizedMin = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? startOfDay
        } else {
            normalizedMin = startOfDay
        }
        
        // Normalize maximumTime to today
        let normalizedMax: Date
        if let maxTime = maximumTime {
            let hour = calendar.component(.hour, from: maxTime)
            let minute = calendar.component(.minute, from: maxTime)
            normalizedMax = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? endOfDay
        } else {
            normalizedMax = endOfDay
        }
        
        // Ensure min <= max (with at least 1 minute gap)
        if normalizedMin < normalizedMax {
            return normalizedMin...normalizedMax
        } else {
            // Fallback: allow the minimum time only
            return normalizedMin...normalizedMin
        }
    }
}

// MARK: - Stacked Schedule Time Rows

/// Two stacked time rows for "From" and "To" with shared styling.
/// Automatically handles validation between the two times.
struct ScheduleTimeStack: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    /// Minimum gap between start and end (in minutes). Default: 1 hour.
    var minimumGapMinutes: Int = 60
    
    var body: some View {
        VStack(spacing: 0) {
            // From row: can go from 12:00 AM up to (endTime - gap)
            ScheduleTimeRowInline(
                label: "From",
                time: $startTime,
                minimumTime: nil,
                maximumTime: maxStartTime
            )
            .onChange(of: startTime) { _, newStart in
                // Ensure end time stays valid (at least minimumGap after start)
                let calendar = Calendar.current
                let startHour = calendar.component(.hour, from: newStart)
                let startMinute = calendar.component(.minute, from: newStart)
                let startTotalMinutes = startHour * 60 + startMinute
                
                let endHour = calendar.component(.hour, from: endTime)
                let endMinute = calendar.component(.minute, from: endTime)
                let endTotalMinutes = endHour * 60 + endMinute
                
                if endTotalMinutes < startTotalMinutes + minimumGapMinutes {
                    // Push end time forward
                    let newEndMinutes = startTotalMinutes + minimumGapMinutes
                    let newEndHour = min(23, newEndMinutes / 60)
                    let newEndMinute = newEndMinutes % 60
                    endTime = calendar.date(bySettingHour: newEndHour, minute: newEndMinute, second: 0, of: Date()) ?? endTime
                }
            }
            
            // Separator line between the two rows
            Rectangle()
                .fill(ZenoSemanticTokens.Theme.border)
                .frame(height: 1)
                .padding(.horizontal, ZenoSemanticTokens.Space.lg)
            
            // To row: can go from (startTime + gap) to 11:59 PM
            ScheduleTimeRowInline(
                label: "To",
                time: $endTime,
                minimumTime: minEndTime,
                maximumTime: nil
            )
        }
        .background(ZenoSemanticTokens.Theme.card)
        .cornerRadius(ZenoSemanticTokens.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.md)
                .stroke(ZenoSemanticTokens.Theme.border, lineWidth: ZenoSemanticTokens.Stroke.thin)
        )
    }
    
    // MARK: - Computed Constraints
    
    /// Maximum allowed start time (endTime - minimumGap)
    private var maxStartTime: Date {
        let calendar = Calendar.current
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        let endTotalMinutes = endHour * 60 + endMinute
        
        let maxStartMinutes = max(0, endTotalMinutes - minimumGapMinutes)
        let maxHour = maxStartMinutes / 60
        let maxMinute = maxStartMinutes % 60
        
        return calendar.date(bySettingHour: maxHour, minute: maxMinute, second: 0, of: Date()) ?? startTime
    }
    
    /// Minimum allowed end time (startTime + minimumGap)
    private var minEndTime: Date {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let startTotalMinutes = startHour * 60 + startMinute
        
        let minEndMinutes = min(23 * 60 + 59, startTotalMinutes + minimumGapMinutes)
        let minHour = minEndMinutes / 60
        let minMinute = minEndMinutes % 60
        
        return calendar.date(bySettingHour: minHour, minute: minMinute, second: 0, of: Date()) ?? endTime
    }
}

// MARK: - Inline Time Row (No Card Styling)

/// Internal row used within ScheduleTimeStack - no background/border styling.
private struct ScheduleTimeRowInline: View {
    let label: String
    @Binding var time: Date
    var minimumTime: Date?
    var maximumTime: Date?
    
    @State private var isPickerPresented = false
    @State private var editingTime: Date = Date()
    
    var body: some View {
        Button(action: openPicker) {
            HStack(spacing: ZenoSemanticTokens.Space.md) {
                Text(label)
                    .font(ZenoTokens.Typography.labelLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.foreground)
                
                Spacer()
                
                Text(formattedTime)
                    .font(ZenoTokens.Typography.labelLarge)
                    .foregroundColor(ZenoSemanticTokens.Theme.accentForeground)
                
                Image(systemName: "chevron.right")
                    .font(ZenoTokens.Typography.labelSmall.weight(.bold))
                    .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            }
            .padding(ZenoSemanticTokens.Space.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPickerPresented) {
            TimePickerSheet(
                label: label,
                time: $editingTime,
                minimumTime: minimumTime,
                maximumTime: maximumTime,
                onSave: saveTime,
                onCancel: cancelEdit
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    private func openPicker() {
        // Normalize time to today for consistent picker behavior
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        editingTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? time
        isPickerPresented = true
    }
    
    private func saveTime() {
        time = editingTime
        isPickerPresented = false
    }
    
    private func cancelEdit() {
        isPickerPresented = false
    }
}

// MARK: - Preview

#Preview("Single Row") {
    ZStack {
        ZenoSemanticTokens.Theme.background.ignoresSafeArea()
        
        ScheduleTimeRow(
            label: "From",
            time: .constant(Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!)
        )
        .padding()
    }
}

#Preview("Stacked Rows") {
    ZStack {
        ZenoSemanticTokens.Theme.background.ignoresSafeArea()
        
        ScheduleTimeStack(
            startTime: .constant(Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!),
            endTime: .constant(Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!)
        )
        .padding()
    }
}

