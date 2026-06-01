//
//  SettingsStore.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation
import ServiceManagement
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    @Published var shouldTimerRun: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.shouldTimerRun) as? Bool ?? Defaults.shouldTimerRun {
        didSet {
            UserDefaults.standard.set(shouldTimerRun, forKey: UserDefaultsKey.shouldTimerRun)
        }
    }

    @Published var workInterval: Int = UserDefaults.standard.object(forKey: UserDefaultsKey.workInterval) as? Int ?? Defaults.workInterval {
        didSet {
            UserDefaults.standard.set(workInterval, forKey: UserDefaultsKey.workInterval)
            if !isBreakTimeNow {
                onWorkIntervalChanged?(workInterval)
            }
        }
    }

    @Published var breakInterval: Int = UserDefaults.standard.object(forKey: UserDefaultsKey.breakInterval) as? Int ?? Defaults.breakInterval {
        didSet {
            UserDefaults.standard.set(breakInterval, forKey: UserDefaultsKey.breakInterval)
            if isBreakTimeNow {
                onBreakIntervalChanged?(breakInterval)
            }
        }
    }

    @Published var isSoundEnabled: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.isSoundEnabled) as? Bool ?? Defaults.isSoundEnabled {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: UserDefaultsKey.isSoundEnabled)
        }
    }

    @Published var launchAtLogin: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.launchAtLogin) as? Bool ?? Defaults.launchAtLogin {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: UserDefaultsKey.launchAtLogin)
            updateLaunchAtLogin()
        }
    }

    @Published var isBreakTimeNow = false

    var onWorkIntervalChanged: ((Int) -> Void)?
    var onBreakIntervalChanged: ((Int) -> Void)?

    func resetToDefaults() {
        shouldTimerRun = Defaults.shouldTimerRun
        workInterval = Defaults.workInterval
        breakInterval = Defaults.breakInterval
        isSoundEnabled = Defaults.isSoundEnabled
    }

    private func updateLaunchAtLogin() {
        SMLoginItemSetEnabled(Constants.helperBundleID as CFString, launchAtLogin)
    }
}
