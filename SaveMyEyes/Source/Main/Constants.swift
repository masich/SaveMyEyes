//
//  Constants.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/26/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

// TODO: make it possible to take these values from user
public let timeIntervals = [15, 20, 30, 40, 60, 90, 120]
public let breakTimes = [1, 2, 5, 10, 15, 20, 30]

// Timer will tick every 1 minute
public let timerInternalInterval: TimeInterval = 1 * 60

// If user is inactive for more than `allowedUserInactivityInterval` seconds -> internal timer will be paused
public let allowedUserInactivityInterval: TimeInterval = 5 * 60
