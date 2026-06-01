//
//  Constants.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/26/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

enum Defaults {
    static let shouldTimerRun = false
    static let workInterval = 25 // minutes
    static let breakInterval = 5 // minutes
    static let isSoundEnabled = true
    static let launchAtLogin = false
}

enum Constants {
    static let workIntervalRange = 1...150 // minutes
    static let breakIntervalRange = 1...60 // minutes
    static let minute: TimeInterval = 60 // minutes to seconds

    // If user is inactive for more than this, the internal timer pauses
    static let allowedUserInactivityMinutes = 5
    static let allowedUserInactivityInterval: TimeInterval = TimeInterval(allowedUserInactivityMinutes) * minute

    // Bundle ID for helper app to automatically launch SaveMyEyes at startup
    static let helperBundleID = "com.masich.SaveMyEyesLauncher"
}

// MARK: - UserDefaults Keys
enum UserDefaultsKey {
    static let shouldTimerRun = "ShouldTimerRun"
    static let workInterval = "WorkTimeInterval"
    static let breakInterval = "BreakTimeInterval"
    static let isSoundEnabled = "IsSoundEnabled"
    static let launchAtLogin = "LaunchAtLogin"
    static let remainingMinutes = "RemainingMinutes"
    static let isBreakTimeNow = "IsBreakTimeNow"
}
