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
@MainActor
final class MainViewModel {
    let settings: SettingsStore
    private(set) var timer: BreakTimer!

    var launchAtLoginError: String?
    var isNotificationsDenied = false
    var onTimerRunStateChanged: ((Bool) -> Void)?
    var onRemainingSecondsChanged: ((Int) -> Void)?

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

        timer.onRemainingSecondsChanged = { [weak self] seconds in
            self?.onRemainingSecondsChanged?(seconds)
        }
        settings.onTimerRunStateChanged = { [weak self] shouldRun in
            guard let self else { return }
            if shouldRun {
                self.timer.start()
            } else {
                self.timer.stop()
            }
            self.onTimerRunStateChanged?(shouldRun)
        }
        settings.onWorkIntervalChanged = { [weak self] oldInterval, newInterval in
            self?.timer.updateWorkInterval(from: oldInterval, to: newInterval)
        }
        settings.onBreakIntervalChanged = { [weak self] oldInterval, newInterval in
            self?.timer.updateBreakInterval(from: oldInterval, to: newInterval)
        }
        settings.onLaunchAtLoginError = { [weak self] message in
            self?.launchAtLoginError = message
        }
    }

    func startTimer() { timer.start() }
    func stopTimer() { timer.stop() }

    func refreshNotificationAuthorizationStatus() {
        AppNotificationManager.getAuthorizationStatus { [weak self] status in
            Task { @MainActor [weak self] in
                self?.isNotificationsDenied = (status == .denied)
            }
        }
    }

    func sendNotification() {
        let sound = settings.isSoundEnabled ? AppNotification.defaultSound : AppNotification.withoutSound
        if timer.isBreakTimeNow {
            AppNotificationManager.sendSingle(AppNotification(
                title: "It's time for a break".localized,
                subtitle: String(format: "Step away for %d min".localized, settings.breakInterval),
                sound: sound,
                categoryIdentifier: AppNotification.Category.breakReminder
            ))
        } else {
            AppNotificationManager.sendSingle(AppNotification(
                title: "It's time to work".localized,
                subtitle: "Let's continue to do amazing things!".localized,
                sound: sound,
                categoryIdentifier: AppNotification.Category.workReminder
            ))
        }
    }

    func pauseTimer() { timer.pause() }

    func toggleBreakState() {
        timer.toggleBreakState()
        AppNotificationManager.removeAllNotifications()
    }

    func snoozeBreak() {
        guard timer.isBreakTimeNow else { return }
        timer.snoozeBreak()
        AppNotificationManager.removeAllNotifications()
        if !settings.shouldTimerRun {
            settings.shouldTimerRun = true
        }
    }

    func skipBreak() {
        timer.skipBreak()
        AppNotificationManager.removeAllNotifications()
    }

    func handleWake() { timer.handleWake() }

    func persistTimerState() { timer.persist() }

    func resetToDefaults() {
        settings.resetToDefaults()
        timer.resetToDefaults(workInterval: settings.workInterval, breakInterval: settings.breakInterval)
        AppNotificationManager.removeAllNotifications()
    }

    func quit() { terminateApp() }
}
