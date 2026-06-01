//
//  BreakTimer.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
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

    private let tickInterval: TimeInterval
    private let settings: SettingsStore
    private let onNotification: () -> Void
    private let onBreakStateChanged: (Bool) -> Void

    init(
        tickInterval: TimeInterval,
        settings: SettingsStore,
        onNotification: @escaping () -> Void,
        onBreakStateChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.tickInterval = tickInterval
        self.settings = settings
        self.onNotification = onNotification
        self.onBreakStateChanged = onBreakStateChanged

        // Restore persisted state or use defaults
        let wasBreak = UserDefaults.standard.bool(forKey: UserDefaultsKey.isBreakTimeNow)
        let savedRemaining = UserDefaults.standard.integer(forKey: UserDefaultsKey.remainingSeconds)

        isBreakTimeNow = wasBreak
        remainingSeconds = savedRemaining > 0
            ? savedRemaining
            : (wasBreak ? settings.breakInterval : settings.workInterval) * 60

        persistState()
    }

    deinit {
        timer?.invalidate()
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        Log.timer.info("Timer started — \(self.isBreakTimeNow ? "break" : "work"), \(self.remainingSeconds)s remaining")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        Log.timer.info("Timer stopped")
    }

    func pause() {
        settings.shouldTimerRun = false
    }

    func updateRemainingForWorkInterval(_ interval: Int) {
        if !isBreakTimeNow {
            remainingSeconds = interval * 60
            persistState()
        }
    }

    func updateRemainingForBreakInterval(_ interval: Int) {
        if isBreakTimeNow {
            remainingSeconds = interval * 60
            persistState()
        }
    }

    #if DEBUG
    func simulateTick() {
        tick()
    }

    func testSetBreakState(_ isBreak: Bool) {
        isBreakTimeNow = isBreak
    }
    #endif

    // MARK: - Private

    private func tick() {
        let inactiveSeconds = SystemIdle.userInactiveSeconds() ?? 0
        let isInactiveNow = inactiveSeconds >= Constants.allowedUserInactivityInterval

        // If user just went idle, extend work time
        if !isUserInactive && isInactiveNow && !isBreakTimeNow {
            let maxIncrement = (settings.workInterval * 60) - remainingSeconds
            let increment = min(maxIncrement, Int(Constants.allowedUserInactivityInterval))
            remainingSeconds += increment
        }
        isUserInactive = isInactiveNow

        // Count down if in break or if user is active
        if isBreakTimeNow || !isUserInactive {
            remainingSeconds -= 1

            if remainingSeconds <= 0 {
                if isBreakTimeNow {
                    remainingSeconds = settings.workInterval * 60
                } else {
                    remainingSeconds = settings.breakInterval * 60
                }
                isBreakTimeNow.toggle()
                onBreakStateChanged(isBreakTimeNow)
                onNotification()
                Log.timer.info("State changed — now \(self.isBreakTimeNow ? "break" : "work")")
            }
        }

        persistState()
    }

    private func persistState() {
        UserDefaults.standard.set(remainingSeconds, forKey: UserDefaultsKey.remainingSeconds)
        UserDefaults.standard.set(isBreakTimeNow, forKey: UserDefaultsKey.isBreakTimeNow)
    }
}
