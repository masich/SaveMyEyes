//
//  SettingsStore.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation
import ServiceManagement
import Observation

@Observable
final class SettingsStore {
    var onTimerRunStateChanged: ((Bool) -> Void)?

    var shouldTimerRun: Bool {
        didSet {
            UserDefaults.standard.set(shouldTimerRun, forKey: UserDefaultsKey.shouldTimerRun)
            onTimerRunStateChanged?(shouldTimerRun)
        }
    }

    var workInterval: Int {
        didSet {
            UserDefaults.standard.set(workInterval, forKey: UserDefaultsKey.workInterval)
            if !isBreakTimeNow { onWorkIntervalChanged?(workInterval) }
        }
    }

    var breakInterval: Int {
        didSet {
            UserDefaults.standard.set(breakInterval, forKey: UserDefaultsKey.breakInterval)
            if isBreakTimeNow { onBreakIntervalChanged?(breakInterval) }
        }
    }

    var isSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(isSoundEnabled, forKey: UserDefaultsKey.isSoundEnabled) }
    }

    var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: UserDefaultsKey.launchAtLogin)
            updateLaunchAtLogin()
        }
    }

    var isBreakTimeNow: Bool {
        didSet { UserDefaults.standard.set(isBreakTimeNow, forKey: UserDefaultsKey.isBreakTimeNow) }
    }

    var onWorkIntervalChanged: ((Int) -> Void)?
    var onBreakIntervalChanged: ((Int) -> Void)?

    init() {
        let defaults = UserDefaults.standard
        shouldTimerRun = defaults.object(forKey: UserDefaultsKey.shouldTimerRun) as? Bool ?? Defaults.shouldTimerRun
        workInterval = defaults.object(forKey: UserDefaultsKey.workInterval) as? Int ?? Defaults.workInterval
        breakInterval = defaults.object(forKey: UserDefaultsKey.breakInterval) as? Int ?? Defaults.breakInterval
        isSoundEnabled = defaults.object(forKey: UserDefaultsKey.isSoundEnabled) as? Bool ?? Defaults.isSoundEnabled
        launchAtLogin = defaults.object(forKey: UserDefaultsKey.launchAtLogin) as? Bool ?? Defaults.launchAtLogin
        isBreakTimeNow = defaults.bool(forKey: UserDefaultsKey.isBreakTimeNow)
    }

    func resetToDefaults() {
        shouldTimerRun = Defaults.shouldTimerRun
        workInterval = Defaults.workInterval
        breakInterval = Defaults.breakInterval
        isSoundEnabled = Defaults.isSoundEnabled
    }

    private func updateLaunchAtLogin() {
        let helperID = Constants.helperBundleID
        if #available(macOS 13.0, *) {
            do {
                let service = SMAppService.loginItem(identifier: helperID)
                if launchAtLogin {
                    try service.register()
                } else {
                    try service.unregister()
                }
            } catch {
                Log.system.error("Failed to update launch-at-login: \(error.localizedDescription)")
            }
        }
    }
}
