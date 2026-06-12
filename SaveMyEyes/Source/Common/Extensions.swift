//
//  Extensions.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/25/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation
import SwiftUI

extension String {
    /// Returns localized string value.
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    var localizedUserNotification: String {
        NSString.localizedUserNotificationString(forKey: self, arguments: nil)
    }
}

extension UserDefaults {
    /// Returns stored value for provided `key` or `nil` if there is no stored value available for a `key`.
    func optional<T>(forKey key: String) -> T? {
        value(forKey: key) as? T
    }

    /// Returns stored value for provided `key` or `defaultValue` if there is no stored value available for a `key`.
    func value<T>(forKey key: String, defaultValue: T) -> T {
        optional(forKey: key) ?? defaultValue
    }
}

extension Int {
    /// Formats seconds as "mm:ss" duration string (e.g., 1500 -> "25:00", 299 -> "04:59").
    var asDurationString: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
