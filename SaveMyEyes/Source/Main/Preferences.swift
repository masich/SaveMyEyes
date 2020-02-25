//
//  File.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/25/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

private let defaults = UserDefaults.standard

func getSelectedTimeIntervalValue() -> Int? {
    return defaults.integer(forKey: "SelectedTimeInterval")
}

func getSelectedBreakTimeValue() -> Int? {
    return defaults.integer(forKey: "SelectedBreakTime")
}

func setSelectedTimeIntervalValue(_ value: Int) {
    defaults.set(value, forKey: "SelectedTimeInterval")
}

func setSelectedBreakTimeValue(_ value: Int) {
    defaults.set(value, forKey: "SelectedBreakTime")
}
