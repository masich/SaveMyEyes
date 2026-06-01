//
//  Logger.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import os.log

enum Log {
    static let notifications = Logger(subsystem: Constants.mainBundleID, category: "notifications")
    static let timer = Logger(subsystem: Constants.mainBundleID, category: "timer")
    static let system = Logger(subsystem: Constants.mainBundleID, category: "system")
}
