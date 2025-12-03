import Foundation
import Observation
import FamilyControls

/// Represents the available time durations for unblocking apps
enum UnblockDuration: Int, CaseIterable, Identifiable {
    case twoMinutes = 2
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    
    var id: Int { rawValue }
    
    var displayText: String {
        "\(rawValue) min"
    }
}

@Observable
class HomeViewModel {
    // MARK: - Step & Credit Properties
    var steps: Int = 0
    var creditsEarned: Int = 0
    var creditsSpent: Int = 0
    var creditsAvailable: Int = 0
    var stepsAvailable: Int = 0
    
    // MARK: - Blocking Properties
    var blockedAppsCount: Int = 0
    var blockedCategoriesCount: Int = 0
    var blockedWebDomainsCount: Int = 0
    
    /// Whether apps are currently blocked (shield is active)
    var isBlocking: Bool = false
    
    /// The selected duration for unblocking
    var selectedDuration: UnblockDuration? = nil
    
    /// Whether an unblock operation is in progress
    var isUnblocking: Bool = false
    
    // MARK: - Timer Properties
    
    /// Remaining time in the current unblock session (in seconds)
    var remainingSeconds: Int = 0
    
    /// The initial duration of the current session (in seconds) - used for progress calculation
    var initialSessionSeconds: Int = 0
    
    /// The timer that updates remaining time
    private var countdownTimer: Timer?
    
    // MARK: - Step Observation
    
    /// Task that handles real-time step observation
    private var stepObservationTask: Task<Void, Never>?
    
    /// Whether step observation is currently active
    var isObservingSteps: Bool = false
    
    // MARK: - Error Handling
    var errorMessage: String? = nil
    
    // MARK: - Dependencies
    private let healthService: HealthDataProviding
    private let stepStore: StepCreditsStoring
    private let appsStore: ManagedAppsStoring
    private let blockingService: AppBlockingService
    
    // Hardcoded for display purposes as it is private in Ledger
    private let stepsPerMinute: Int = 100
    
    // MARK: - Init
    
    init(
        healthService: HealthDataProviding = HealthKitService(),
        stepStore: StepCreditsStoring = LocalStepCreditsStore(),
        appsStore: ManagedAppsStoring = LocalManagedAppsStore(),
        blockingService: AppBlockingService = .shared
    ) {
        self.healthService = healthService
        self.stepStore = stepStore
        self.appsStore = appsStore
        self.blockingService = blockingService
    }
    
    // MARK: - Computed Properties
    
    /// Whether the user can afford at least one unlock duration (used to show/hide duration chips)
    var canAffordAnyDuration: Bool {
        // Check if user can afford the minimum duration (2 min)
        guard let minDuration = UnblockDuration.allCases.min(by: { $0.rawValue < $1.rawValue }) else {
            return false
        }
        return creditsAvailable >= minDuration.rawValue
    }
    
    /// Returns only the durations the user can afford (filters out unaffordable options)
    var affordableDurations: [UnblockDuration] {
        UnblockDuration.allCases.filter { creditsAvailable >= $0.rawValue }
    }
    
    /// Returns the available durations and whether each is enabled based on credits
    var availableDurations: [(duration: UnblockDuration, isEnabled: Bool)] {
        UnblockDuration.allCases.map { duration in
            (duration, creditsAvailable >= duration.rawValue)
        }
    }
    
    /// Whether the user can unblock apps (has a selection and enough credits)
    var canUnblock: Bool {
        guard let selected = selectedDuration else { return false }
        return creditsAvailable >= selected.rawValue && hasAppsToBlock
    }
    
    /// Whether there are any apps/categories selected to block
    var hasAppsToBlock: Bool {
        blockedAppsCount > 0 || blockedCategoriesCount > 0
    }
    
    /// Whether there's an active unblock session with time remaining
    var hasActiveUnblockSession: Bool {
        !isBlocking && remainingSeconds > 0
    }
    
    /// Formatted remaining time string (MM:SS)
    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Remaining minutes (rounded up) for display
    var remainingMinutes: Int {
        Int(ceil(Double(remainingSeconds) / 60.0))
    }
    
    /// Progress of the current session (0.0 to 1.0, where 1.0 is full/just started)
    var sessionProgress: CGFloat {
        guard initialSessionSeconds > 0 else { return 0 }
        return CGFloat(remainingSeconds) / CGFloat(initialSessionSeconds)
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        // 1. Load Apps Config (Always load this, independent of HealthKit)
        let config = appsStore.loadConfig()
        await MainActor.run {
            self.blockedAppsCount = config.selection.applicationTokens.count
            self.blockedCategoriesCount = config.selection.categoryTokens.count
            self.blockedWebDomainsCount = config.selection.webDomainTokens.count
            self.isBlocking = blockingService.isBlocking
            
            // Sync timer state from blocking service
            self.syncTimerState()
        }
        
        do {
            // 2. Fetch Steps
            // Note: fetchTodaySteps returns 0 if permissions are not granted or data is missing.
            let steps = try await healthService.fetchTodaySteps()
            
            // 3. Update Store
            stepStore.updateSteps(count: steps)
            
            // 4. Load Ledger
            let ledger = stepStore.loadLedger(for: Date())
            
            await MainActor.run {
                self.steps = ledger.stepsSynced
                self.creditsEarned = ledger.creditsEarned
                self.creditsSpent = ledger.creditsSpent
                self.creditsAvailable = ledger.creditsAvailable
                self.stepsAvailable = ledger.creditsAvailable * stepsPerMinute
                self.errorMessage = nil // Clear previous errors if successful
            }
            
        } catch {
            await MainActor.run {
                // Map technical errors to user-friendly messages
                // "No data available for the specified predicate" means no steps recorded yet - not a real error
                let errorString = error.localizedDescription.lowercased()
                if errorString.contains("predicate") || errorString.contains("no data") {
                    // This is normal - user just hasn't walked yet or data hasn't synced
                    self.errorMessage = nil
                } else {
                    // Genuine error - show user-friendly message
                    self.errorMessage = "We couldn't count your steps. Please check Health permissions in Settings."
                }
                
                // Load local ledger regardless (it might have cached data)
                let ledger = stepStore.loadLedger(for: Date())
                self.steps = ledger.stepsSynced
                self.creditsEarned = ledger.creditsEarned
                self.creditsSpent = ledger.creditsSpent
                self.creditsAvailable = ledger.creditsAvailable
                self.stepsAvailable = ledger.creditsAvailable * stepsPerMinute
            }
        }
    }
    
    // MARK: - Real-Time Step Observation
    
    /// Start observing steps in real-time. Call when app becomes active.
    func startObservingSteps() {
        // Don't start if already observing
        guard !isObservingSteps else { return }
        
        isObservingSteps = true
        print("DEBUG: Starting step observation in ViewModel")
        
        stepObservationTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Get the stream from the health service
            let stepStream = self.healthService.observeTodaySteps()
            
            // Iterate over incoming step updates
            for await steps in stepStream {
                // Check if task was cancelled
                if Task.isCancelled { break }
                
                // Update the store with new step count
                self.stepStore.updateSteps(count: steps)
                
                // Load updated ledger
                let ledger = self.stepStore.loadLedger(for: Date())
                
                // Update UI on main actor
                await MainActor.run {
                    self.steps = ledger.stepsSynced
                    self.creditsEarned = ledger.creditsEarned
                    self.creditsSpent = ledger.creditsSpent
                    self.creditsAvailable = ledger.creditsAvailable
                    self.stepsAvailable = ledger.creditsAvailable * self.stepsPerMinute
                    self.errorMessage = nil
                }
            }
        }
    }
    
    /// Stop observing steps. Call when app goes to background.
    func stopObservingSteps() {
        guard isObservingSteps else { return }
        
        print("DEBUG: Stopping step observation in ViewModel")
        
        stepObservationTask?.cancel()
        stepObservationTask = nil
        healthService.stopObservingSteps()
        isObservingSteps = false
    }
    
    // MARK: - Debug Methods
    
    /// Spend all available credits (for testing "Walk Now" feature)
    func debugSpendAllCredits() {
        guard creditsAvailable > 0 else { return }
        
        do {
            try stepStore.spendCredits(minutes: creditsAvailable)
            
            // Reload ledger to update UI
            let ledger = stepStore.loadLedger(for: Date())
            creditsSpent = ledger.creditsSpent
            creditsAvailable = ledger.creditsAvailable
            stepsAvailable = ledger.creditsAvailable * stepsPerMinute
        } catch {
            errorMessage = "Debug: Failed to spend credits"
        }
    }
    
    /// Select or deselect a duration for unblocking
    func selectDuration(_ duration: UnblockDuration) {
        guard creditsAvailable >= duration.rawValue else { return }
        
        // Toggle: if already selected, deselect it
        if selectedDuration == duration {
            selectedDuration = nil
        } else {
            selectedDuration = duration
        }
    }
    
    /// Block all selected apps (apply shields)
    /// If called during an active unblock session, refunds unused time
    func blockApps() {
        // Calculate refund before blocking
        let refundMinutes = blockingService.remainingMinutes
        
        // Stop the timer
        stopCountdownTimer()
        
        // Apply the block
        blockingService.blockApps()
        isBlocking = true
        remainingSeconds = 0
        initialSessionSeconds = 0
        
        // Refund unused credits if there was time remaining
        if refundMinutes > 0 {
            stepStore.refundCredits(minutes: refundMinutes)
            
            // Update credits display
            let ledger = stepStore.loadLedger(for: Date())
            creditsSpent = ledger.creditsSpent
            creditsAvailable = ledger.creditsAvailable
            stepsAvailable = ledger.creditsAvailable * stepsPerMinute
        }
        
        // Clear selection so user must choose again
        selectedDuration = nil
    }
    
    /// Unblock apps for the selected duration
    func unblockApps() async {
        guard let duration = selectedDuration else { return }
        
        // Reload ledger to ensure we have the latest credit state
        let ledger = stepStore.loadLedger(for: Date())
        creditsSpent = ledger.creditsSpent
        creditsAvailable = ledger.creditsAvailable
        stepsAvailable = ledger.creditsAvailable * stepsPerMinute
        
        guard creditsAvailable >= duration.rawValue else {
            selectedDuration = nil
            errorMessage = "Not enough credits. Walk to earn more minutes!"
            return
        }
        
        isUnblocking = true
        
        do {
            // 1. Spend the credits
            try stepStore.spendCredits(minutes: duration.rawValue)
            
            // 2. Log the unlock session
            appsStore.logUnlock(duration: duration.rawValue, cost: duration.rawValue * stepsPerMinute, appName: nil)
            
            // 3. Remove shields
            blockingService.unblockApps(for: duration.rawValue)
            
            await MainActor.run {
                self.isBlocking = false
                self.isUnblocking = false
                self.selectedDuration = nil
                
                // Update credits display
                let ledger = stepStore.loadLedger(for: Date())
                self.creditsSpent = ledger.creditsSpent
                self.creditsAvailable = ledger.creditsAvailable
                self.stepsAvailable = ledger.creditsAvailable * stepsPerMinute
                
                // Start the countdown timer
                self.startCountdownTimer(duration: duration.rawValue)
            }
            
        } catch {
            await MainActor.run {
                self.isUnblocking = false
                
                // Reload ledger to sync UI state with actual credits
                let ledger = self.stepStore.loadLedger(for: Date())
                self.creditsSpent = ledger.creditsSpent
                self.creditsAvailable = ledger.creditsAvailable
                self.stepsAvailable = ledger.creditsAvailable * self.stepsPerMinute
                
                // Clear selection since the operation failed
                self.selectedDuration = nil
                
                // Map technical errors to user-friendly messages
                if let stepError = error as? StepCreditsError {
                    switch stepError {
                    case .insufficientCredits:
                        self.errorMessage = "Not enough credits. Walk to earn more minutes!"
                    case .ledgerNotFound:
                        self.errorMessage = "Something went wrong. Please try again."
                    }
                } else {
                    self.errorMessage = "Failed to unblock apps. Please try again."
                }
            }
        }
    }
    
    // MARK: - Timer Methods
    
    /// Sync timer state from blocking service (e.g., on app launch or returning from background)
    func syncTimerState() {
        let remaining = blockingService.remainingUnblockTime
        if remaining > 0 && !blockingService.isBlocking {
            remainingSeconds = Int(remaining)
            isBlocking = false
            
            // If we don't have initialSessionSeconds (app was restarted), use remaining as fallback
            // This means progress won't be fully accurate but is better than nothing
            if initialSessionSeconds == 0 {
                initialSessionSeconds = remainingSeconds
            }
            
            startCountdownTimer()
        } else if remaining <= 0 && blockingService.isInUnblockSession {
            // Timer expired while in background - trigger reblock
            remainingSeconds = 0
            initialSessionSeconds = 0
            stopCountdownTimer()
            blockingService.blockApps()
            isBlocking = true
        } else {
            remainingSeconds = 0
            initialSessionSeconds = 0
            stopCountdownTimer()
            isBlocking = blockingService.isBlocking
        }
    }
    
    /// Start the countdown timer for an unblock session
    private func startCountdownTimer(duration: Int) {
        let totalSeconds = duration * 60
        initialSessionSeconds = totalSeconds
        remainingSeconds = totalSeconds
        startCountdownTimer()
    }
    
    /// Start or resume the countdown timer
    /// The timer recalculates from actual expiry time each tick (handles background correctly)
    private func startCountdownTimer() {
        stopCountdownTimer()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Always recalculate from the actual expiry time
            // This handles the case where app was backgrounded
            let remaining = self.blockingService.remainingUnblockTime
            self.remainingSeconds = Int(remaining)
            
            // When timer reaches 0, trigger reblock
            if self.remainingSeconds <= 0 {
                self.stopCountdownTimer()
                self.remainingSeconds = 0
                self.blockingService.blockApps()
                self.isBlocking = true
            }
        }
    }
    
    /// Stop the countdown timer
    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}
