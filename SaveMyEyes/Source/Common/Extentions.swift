//
//  Extentions.swift
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
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    var localizedUserNotification: String {
        return NSString.localizedUserNotificationString(forKey: self, arguments: nil)
    }
}

extension UserDefaults {
    /// Returns stored value for provided `key` or `nil` if there is no stored value availble for a `key`.
    public func optional<T>(forKey key: String) -> T? {
        return self.value(forKey: key) as? T
    }
    
    /// Returns stored value for provided `key` or `defaultValue` if there is no stored value availble for a `key`.
    public func value<T>(forKey key: String, defaultValue: T) -> T {
        let storedValue: T? = optional(forKey: key)
        return storedValue ?? defaultValue
    }
}
