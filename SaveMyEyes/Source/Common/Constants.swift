//
//  Constants.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko on 2020-02-26.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

enum Defaults {
    static let shouldTimerRun = false
    static let workInterval = 25 // minutes
    static let breakInterval = 5 // minutes
    static let isSoundEnabled = true
    static let snoozeMinutes = 5
}

enum Constants {
    static let workIntervalRange = 1...180 // minutes
    static let breakIntervalRange = 1...180 // minutes
    static let minute: TimeInterval = 60 // seconds per minute

    // If user is inactive for more than this, the internal timer pauses
    static let allowedUserInactivityMinutes = 5
    static let allowedUserInactivityInterval: TimeInterval = TimeInterval(allowedUserInactivityMinutes) * minute

    // Bundle ID for main application
    static let mainBundleID = "com.masich.SaveMyEyes"
}

// MARK: - UserDefaults Keys
enum UserDefaultsKey {
    static let shouldTimerRun = "ShouldTimerRun"
    static let workInterval = "WorkTimeInterval"
    static let breakInterval = "BreakTimeInterval"
    static let isSoundEnabled = "IsSoundEnabled"
    static let remainingSeconds = "RemainingSeconds"
    static let isBreakTimeNow = "IsBreakTimeNow"
}
