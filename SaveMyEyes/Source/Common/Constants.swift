//
//  Constants.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/26/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

struct Constants {    
    public static let workIntervalRange = 1...150 // minutes
    public static let breakIntervalRange = 1...60 // minutes
    
    public static let minute: TimeInterval = 60 // seconds
    
    // If user is inactive for more than `allowedUserInactivityMinutes` minutes -> internal timer will be paused
    public static let allowedUserInactivityMinutes: Int = 5
    public static let allowedUserInactivityInterval: TimeInterval = TimeInterval(allowedUserInactivityMinutes) * minute
}
