//
//  Logger.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import os.log

/// Logging wrapper that uses `Logger` on macOS 11+ and falls back to `OSLog` on older systems.
enum Log {

    // MARK: - Notifications

    static func notificationInfo(_ message: String) {
        if #available(macOS 11.0, *) {
            Logger(subsystem: Constants.helperBundleID, category: "notifications").info("\(message)")
        } else {
            os_log(.info, log: _notificationsOSLog, "%{public}@", message)
        }
    }

    static func notificationError(_ message: String) {
        if #available(macOS 11.0, *) {
            Logger(subsystem: Constants.helperBundleID, category: "notifications").error("\(message)")
        } else {
            os_log(.error, log: _notificationsOSLog, "%{public}@", message)
        }
    }

    static func notificationWarning(_ message: String) {
        if #available(macOS 11.0, *) {
            Logger(subsystem: Constants.helperBundleID, category: "notifications").warning("\(message)")
        } else {
            os_log(.default, log: _notificationsOSLog, "%{public}@", message)
        }
    }

    // MARK: - Timer

    static func timerInfo(_ message: String) {
        if #available(macOS 11.0, *) {
            Logger(subsystem: Constants.helperBundleID, category: "timer").info("\(message)")
        } else {
            os_log(.info, log: _timerOSLog, "%{public}@", message)
        }
    }

    // MARK: - System

    static func systemError(_ message: String) {
        if #available(macOS 11.0, *) {
            Logger(subsystem: Constants.helperBundleID, category: "system").error("\(message)")
        } else {
            os_log(.error, log: _systemOSLog, "%{public}@", message)
        }
    }

    // MARK: - Fallback OSLog handles (pre-macOS 11)

    private static let _notificationsOSLog = OSLog(subsystem: Constants.helperBundleID, category: "notifications")
    private static let _timerOSLog = OSLog(subsystem: Constants.helperBundleID, category: "timer")
    private static let _systemOSLog = OSLog(subsystem: Constants.helperBundleID, category: "system")
}
