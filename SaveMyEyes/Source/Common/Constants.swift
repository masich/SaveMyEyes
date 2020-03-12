//
//  Constants.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/26/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

struct Constants {
    // TODO: make it possible to take these values from user
    public static let workIntervals = [15, 20, 30, 40, 60, 90, 120]
    public static let breakIntervals = [1, 2, 5, 10, 15, 20, 30]
    
    public static let minute: TimeInterval = 60 // seconds
    
    // If user is inactive for more than `allowedUserInactivityMinutes` minutes -> internal timer will be paused
    public static let allowedUserInactivityMinutes: Int = 5
    public static let allowedUserInactivityInterval: TimeInterval = TimeInterval(allowedUserInactivityMinutes) * minute
}
