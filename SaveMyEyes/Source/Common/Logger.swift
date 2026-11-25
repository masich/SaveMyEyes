//
//  Logger.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko.
//  SPDX-License-Identifier: Apache-2.0
//

import os.log

enum Log {
    static let notifications = Logger(subsystem: Constants.mainBundleID, category: "notifications")
    static let timer = Logger(subsystem: Constants.mainBundleID, category: "timer")
    static let system = Logger(subsystem: Constants.mainBundleID, category: "system")
}
