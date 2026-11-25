//
//  BreakTimer.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Observation

@Observable
final class BreakTimer {
    private(set) var remainingSeconds: Int = 0
    private(set) var isBreakTimeNow = false

    var remainingMins: Int { remainingSeconds / 60 }

    private var timer: Timer?
    private var isUserInactive = false
    private var rawRemainingSeconds: Int = 0
    private var lastActiveTimestamp: Date?

    var onRemainingSecondsChanged: ((Int) -> Void)?

    private let tickInterval: TimeInterval
    private let allowedUserInactivityInterval: TimeInterval
    private weak var settings: SettingsStore?
    private let onNotification: () -> Void
    private let onBreakStateChanged: (Bool) -> Void
    private let userInactiveSecondsProvider: () -> Double?

    init(
        tickInterval: TimeInterval,
        allowedUserInactivityInterval: TimeInterval = Constants.allowedUserInactivityInterval,
        settings: SettingsStore,
        onNotification: @escaping () -> Void,
        onBreakStateChanged: @escaping (Bool) -> Void = { _ in },
        userInactiveSecondsProvider: @escaping () -> Double? = { SystemIdle.userInactiveSeconds() }
    ) {
        self.tickInterval = tickInterval
        self.allowedUserInactivityInterval = allowedUserInactivityInterval
        self.settings = settings
        self.onNotification = onNotification
        self.onBreakStateChanged = onBreakStateChanged
        self.userInactiveSecondsProvider = userInactiveSecondsProvider

        // Restore persisted state or use defaults
        let wasBreak = UserDefaults.standard.bool(forKey: UserDefaultsKey.isBreakTimeNow)
        let savedRemaining = UserDefaults.standard.integer(forKey: UserDefaultsKey.remainingSeconds)

        isBreakTimeNow = wasBreak
        let initialSeconds = savedRemaining > 0
            ? savedRemaining
            : (wasBreak ? settings.breakInterval : settings.workInterval) * 60
        rawRemainingSeconds = initialSeconds
        remainingSeconds = initialSeconds

        persistState()
    }

    deinit {
        timer?.invalidate()
    }

    func start() {
        guard timer == nil else { return }
        lastActiveTimestamp = Date()
        let scheduled = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        scheduled.tolerance = 0.1
        timer = scheduled
        Log.timer.info("Timer started — \(self.isBreakTimeNow ? "break" : "work"), \(self.remainingSeconds)s remaining")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        lastActiveTimestamp = nil
        persistState()
        Log.timer.info("Timer stopped")
    }

    func pause() {
        settings?.shouldTimerRun = false
    }

    func resetToDefaults(workInterval: Int, breakInterval: Int) {
        transitionPhase(toBreak: false, seconds: workInterval * 60)
    }

    /// Manually toggle between work and break state.
    func toggleBreakState() {
        let newBreakState = !isBreakTimeNow
        let interval = (newBreakState ? settings?.breakInterval : settings?.workInterval) ?? Defaults.workInterval
        transitionPhase(toBreak: newBreakState, seconds: interval * 60)
        Log.timer.info("State manually toggled — now \(self.isBreakTimeNow ? "break" : "work")")
    }

    func updateWorkInterval(from oldInterval: Int, to newInterval: Int) {
        guard !isBreakTimeNow else { return }
        applyIntervalDelta(from: oldInterval, to: newInterval)
    }

    func updateBreakInterval(from oldInterval: Int, to newInterval: Int) {
        guard isBreakTimeNow else { return }
        applyIntervalDelta(from: oldInterval, to: newInterval)
    }

    func snoozeBreak(minutes: Int = Defaults.snoozeMinutes) {
        guard isBreakTimeNow else { return }
        transitionPhase(toBreak: false, seconds: minutes * 60)
        Log.timer.info("Break snoozed for \(minutes) min")
    }

    func skipBreak() {
        guard isBreakTimeNow else { return }
        let workInterval = settings?.workInterval ?? Defaults.workInterval
        transitionPhase(toBreak: false, seconds: workInterval * 60)
        Log.timer.info("Break skipped — switched to work")
    }

    func handleWake(now: Date = Date()) {
        guard let lastActive = lastActiveTimestamp else { return }
        let elapsed = now.timeIntervalSince(lastActive)

        if isBreakTimeNow && Int(elapsed) >= remainingSeconds {
            let workInterval = settings?.workInterval ?? Defaults.workInterval
            lastActiveTimestamp = now
            transitionPhase(toBreak: false, seconds: workInterval * 60)
            onNotification()
            Log.timer.info("Break completed during sleep — now work")
        } else if !isBreakTimeNow && elapsed >= allowedUserInactivityInterval {
            let workInterval = settings?.workInterval ?? Defaults.workInterval
            lastActiveTimestamp = now
            transitionPhase(toBreak: false, seconds: workInterval * 60, notifyStateChange: false)
            Log.timer.info("Work timer reset after sleep")
        }
    }

    func persist() {
        persistState()
    }

    #if DEBUG
    func simulateTick() {
        tick()
    }

    func testSetBreakState(_ isBreak: Bool) {
        isBreakTimeNow = isBreak
    }

    func testSetLastActiveTimestamp(_ date: Date?) {
        lastActiveTimestamp = date
    }
    #endif

    // MARK: - Private

    private func transitionPhase(toBreak: Bool, seconds: Int, notifyStateChange: Bool = true) {
        isBreakTimeNow = toBreak
        isUserInactive = false
        rawRemainingSeconds = seconds
        remainingSeconds = max(0, rawRemainingSeconds)
        if notifyStateChange {
            onBreakStateChanged(toBreak)
        }
        onRemainingSecondsChanged?(remainingSeconds)
        persistState()
    }

    private func applyIntervalDelta(from oldInterval: Int, to newInterval: Int) {
        rawRemainingSeconds += (newInterval - oldInterval) * 60
        rawRemainingSeconds = min(rawRemainingSeconds, newInterval * 60)
        remainingSeconds = max(0, rawRemainingSeconds)
        onRemainingSecondsChanged?(remainingSeconds)
        persistState()
    }

    private func tick() {
        lastActiveTimestamp = Date()
        let inactiveSeconds = userInactiveSecondsProvider() ?? 0
        let isInactiveNow = inactiveSeconds >= allowedUserInactivityInterval

        // If user just went idle, extend work time
        if !isUserInactive && isInactiveNow && !isBreakTimeNow {
            let workInterval = settings?.workInterval ?? Defaults.workInterval
            let maxIncrement = (workInterval * 60) - rawRemainingSeconds
            let increment = min(maxIncrement, Int(allowedUserInactivityInterval))
            rawRemainingSeconds += increment
            remainingSeconds = max(0, rawRemainingSeconds)
            onRemainingSecondsChanged?(remainingSeconds)
            persistState()
        }
        isUserInactive = isInactiveNow

        // Count down if in break or if user is active
        if isBreakTimeNow || !isUserInactive {
            rawRemainingSeconds -= 1

            if rawRemainingSeconds <= 0 {
                let nextBreak = !isBreakTimeNow
                let interval = nextBreak
                    ? (settings?.breakInterval ?? Defaults.breakInterval)
                    : (settings?.workInterval ?? Defaults.workInterval)
                transitionPhase(toBreak: nextBreak, seconds: interval * 60)
                onNotification()
                Log.timer.info("State changed — now \(self.isBreakTimeNow ? "break" : "work")")
            } else {
                remainingSeconds = max(0, rawRemainingSeconds)
                onRemainingSecondsChanged?(remainingSeconds)
                persistState()
            }
        }
    }

    private func persistState() {
        UserDefaults.standard.set(remainingSeconds, forKey: UserDefaultsKey.remainingSeconds)
        UserDefaults.standard.set(isBreakTimeNow, forKey: UserDefaultsKey.isBreakTimeNow)
    }
}
