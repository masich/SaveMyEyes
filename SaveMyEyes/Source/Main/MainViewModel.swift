//
//  MainViewModel.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 03/03/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    let settings: SettingsStore
    private(set) var timer: BreakTimer!

    private var cancellables = Set<AnyCancellable>()
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
            settings: settings,
            onNotification: { [weak self] in self?.sendNotification() },
            onBreakStateChanged: { [weak self] isBreak in self?.settings.isBreakTimeNow = isBreak }
        )

        settings.onWorkIntervalChanged = { [weak self] interval in
            self?.timer.updateRemainingForWorkInterval(interval)
        }
        settings.onBreakIntervalChanged = { [weak self] interval in
            self?.timer.updateRemainingForBreakInterval(interval)
        }

        // Forward settings changes so SwiftUI views re-render
        settings.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Forward timer changes so the view updates remaining time
        timer.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // React to shouldTimerRun changes
        settings.$shouldTimerRun
            .sink { [weak self] shouldRun in
                if shouldRun { self?.timer.start() } else { self?.timer.stop() }
            }
            .store(in: &cancellables)

        if settings.shouldTimerRun {
            timer.start()
        }
    }

    // MARK: - Actions

    func sendNotification() {
        let sound = settings.isSoundEnabled ? AppNotification.defaultSound : AppNotification.withoutSound
        if timer.isBreakTimeNow {
            let notification = AppNotification(
                title: "It's time for a break".localized,
                subtitle: String(format: "Step away for %d min".localized, settings.breakInterval),
                sound: sound
            )
            AppNotificationManager.sendSingle(notification)
        } else {
            let notification = AppNotification(
                title: "It's time to work".localized,
                subtitle: "Let's continue to do amazing things!".localized,
                sound: sound
            )
            AppNotificationManager.sendSingle(notification)
        }
    }

    func pauseTimer() {
        timer.pause()
    }

    func resetToDefaults() {
        settings.resetToDefaults()
    }

    func quit() {
        terminateApp()
    }
}
