//
//  Constants.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/26/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

struct Defaults {
    public static let shouldTimerRun = false
    public static let workInterval = 15 // minutes
    public static let breakInterval = 1 // minutes
    public static let isSoundEnabled = true
    public static let launchAtLogin = false
}

struct Constants {
    public static let workIntervalRange = 1...150 // minutes
    public static let breakIntervalRange = 1...60 // minutes
    public static let minute: TimeInterval = 60 // seconds
    
    // If user is inactive for more than `allowedUserInactivityMinutes` minutes -> internal timer will be paused
    public static let allowedUserInactivityMinutes: Int = 5
    public static let allowedUserInactivityInterval: TimeInterval = TimeInterval(allowedUserInactivityMinutes) * minute
    // Bundle ID for helper app to automaticaly launch SaveMyEyes at startup
    public static let helperBundleID = "com.masich.SaveMyEyesLauncher"
}
