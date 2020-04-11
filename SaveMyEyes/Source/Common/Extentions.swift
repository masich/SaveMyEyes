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
