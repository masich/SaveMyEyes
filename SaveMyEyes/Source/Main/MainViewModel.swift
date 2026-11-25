//
//  MainViewModel.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko on 2020-03-03.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Observation

@Observable
final class MainViewModel {
    let settings: SettingsStore
    private(set) var timer: BreakTimer!

    var launchAtLoginError: String?
    var onTimerRunStateChanged: ((Bool) -> Void)?

    private let terminateApp: () -> Void

    var isBreakTimeNow: Bool { timer.isBreakTimeNow }
    var remainingMins: Int { timer.remainingMins }
    var remainingSeconds: Int { timer.remainingSeconds }

    init(
        timerInterval: TimeInterval,
        allowedUserInactivityInterval: TimeInterval,
        terminateApp: @escaping () -> Void
    ) {
        self.terminateApp = terminateApp
        self.settings = SettingsStore()

        timer = BreakTimer(
            tickInterval: timerInterval,
            allowedUserInactivityInterval: allowedUserInactivityInterval,
            settings: settings,
            onNotification: { [weak self] in self?.sendNotification() },
            onBreakStateChanged: { [weak self] isBreak in self?.settings.isBreakTimeNow = isBreak }
        )

        settings.onTimerRunStateChanged = { [weak self] shouldRun in
            guard let self else { return }
            if shouldRun {
                self.timer.start()
            } else {
                self.timer.stop()
            }
            self.onTimerRunStateChanged?(shouldRun)
        }
        settings.onWorkIntervalChanged = { [weak self] interval in
            self?.timer.updateRemainingForWorkInterval(interval)
        }
        settings.onBreakIntervalChanged = { [weak self] interval in
            self?.timer.updateRemainingForBreakInterval(interval)
        }
        settings.onLaunchAtLoginError = { [weak self] message in
            self?.launchAtLoginError = message
        }
    }

    func startTimer() { timer.start() }
    func stopTimer() { timer.stop() }

    func sendNotification() {
        let sound = settings.isSoundEnabled ? AppNotification.defaultSound : AppNotification.withoutSound
        if timer.isBreakTimeNow {
            AppNotificationManager.sendSingle(AppNotification(
                title: "It's time for a break".localized,
                subtitle: String(format: "Step away for %d min".localized, settings.breakInterval),
                sound: sound
            ))
        } else {
            AppNotificationManager.sendSingle(AppNotification(
                title: "It's time to work".localized,
                subtitle: "Let's continue to do amazing things!".localized,
                sound: sound
            ))
        }
    }

    func pauseTimer() { timer.pause() }

    func toggleBreakState() { timer.toggleBreakState() }

    func resetToDefaults() {
        settings.resetToDefaults()
        timer.resetToDefaults(workInterval: settings.workInterval, breakInterval: settings.breakInterval)
    }

    func quit() { terminateApp() }
}
