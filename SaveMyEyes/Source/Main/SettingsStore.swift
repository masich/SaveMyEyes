//
//  SettingsStore.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko.
//  SPDX-License-Identifier: Apache-2.0
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
            if !isBreakTimeNow { onWorkIntervalChanged?(oldValue, workInterval) }
        }
    }

    var breakInterval: Int {
        didSet {
            UserDefaults.standard.set(breakInterval, forKey: UserDefaultsKey.breakInterval)
            if isBreakTimeNow { onBreakIntervalChanged?(oldValue, breakInterval) }
        }
    }

    var isSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(isSoundEnabled, forKey: UserDefaultsKey.isSoundEnabled) }
    }

    /// Launch-at-login state. The source of truth is SMAppService.mainApp.status.
    var launchAtLogin: Bool = false

    var isBreakTimeNow: Bool {
        didSet { UserDefaults.standard.set(isBreakTimeNow, forKey: UserDefaultsKey.isBreakTimeNow) }
    }

    var onWorkIntervalChanged: ((Int, Int) -> Void)?
    var onBreakIntervalChanged: ((Int, Int) -> Void)?
    var onLaunchAtLoginError: ((String?) -> Void)?

    init() {
        let defaults = UserDefaults.standard
        shouldTimerRun = defaults.object(forKey: UserDefaultsKey.shouldTimerRun) as? Bool ?? Defaults.shouldTimerRun
        workInterval = defaults.object(forKey: UserDefaultsKey.workInterval) as? Int ?? Defaults.workInterval
        breakInterval = defaults.object(forKey: UserDefaultsKey.breakInterval) as? Int ?? Defaults.breakInterval
        isSoundEnabled = defaults.object(forKey: UserDefaultsKey.isSoundEnabled) as? Bool ?? Defaults.isSoundEnabled
        isBreakTimeNow = defaults.bool(forKey: UserDefaultsKey.isBreakTimeNow)

        // Sync with the actual system state on every launch
        syncLaunchAtLoginFromSystem()
    }

    /// Updates the launch-at-login preference from user interaction and syncs with system registration.
    func setLaunchAtLogin(_ enabled: Bool) {
        launchAtLogin = enabled
        syncLaunchAtLogin()
    }

    /// Reads the actual system registration state and updates the property accordingly.
    /// Called on app launch and can be called to re-sync after external changes.
    func syncLaunchAtLoginFromSystem() {
        let status = SMAppService.mainApp.status
        switch status {
        case .enabled:
            launchAtLogin = true
        case .notRegistered:
            launchAtLogin = false
        case .requiresApproval:
            // User hasn't approved yet in System Settings — treat as disabled
            launchAtLogin = false
        case .notFound:
            // App may have been moved or deleted — treat as disabled
            launchAtLogin = false
        @unknown default:
            launchAtLogin = false
        }
    }

    func resetToDefaults() {
        shouldTimerRun = Defaults.shouldTimerRun
        isBreakTimeNow = false
        workInterval = Defaults.workInterval
        breakInterval = Defaults.breakInterval
        isSoundEnabled = Defaults.isSoundEnabled
    }

    /// Syncs the system registration to match the user's desired state.
    /// Follows best practices: checks current status first, handles all states,
    /// and provides user-facing error messages.
    func syncLaunchAtLogin() {
        let service = SMAppService.mainApp
        let currentStatus = service.status

        // Already in the desired state — nothing to do
        if launchAtLogin && currentStatus == .enabled {
            onLaunchAtLoginError?(nil)
            return
        }
        if !launchAtLogin && currentStatus == .notRegistered {
            onLaunchAtLoginError?(nil)
            return
        }

        // User wants to register but it requires approval
        if launchAtLogin && currentStatus == .requiresApproval {
            launchAtLogin = false
            onLaunchAtLoginError?("Open System Settings → General → Login Items to allow this app to launch at login.".localized)
            return
        }

        do {
            if launchAtLogin {
                try service.register()
            } else {
                try service.unregister()
            }
            onLaunchAtLoginError?(nil)
        } catch {
            // Revert to match actual system state
            launchAtLogin = service.status == .enabled

            Log.system.error("Failed to update launch-at-login: \(error.localizedDescription)")
            onLaunchAtLoginError?(error.localizedDescription)
        }
    }
}
