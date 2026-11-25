//
//  Extensions.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko on 2020-02-25.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension String {
    /// Returns localized string value.
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension Int {
    /// Formats seconds as "m:ss" duration string (e.g., 1500 -> "25:00", 299 -> "4:59").
    var asDurationString: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Formats seconds as zero-padded "mm:ss" for fixed-width displays (e.g. menu bar: 599 -> "09:59").
    var asPaddedDurationString: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
