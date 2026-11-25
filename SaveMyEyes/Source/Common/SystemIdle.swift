//
//  SystemIdle.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import IOKit
import os.log

/// Provides system idle time detection via IOKit.
enum SystemIdle {

    /// Returns the number of seconds since the last user input event.
    static func userInactiveSeconds() -> Double? {
        var iterator: io_iterator_t = 0
        defer { IOObjectRelease(iterator) }

        guard IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IOHIDSystem"),
            &iterator
        ) == KERN_SUCCESS else {
            Log.system.error("Failed to get IOHIDSystem matching services")
            return nil
        }

        let entry = IOIteratorNext(iterator)
        defer { IOObjectRelease(entry) }

        guard entry != 0 else {
            Log.system.error("Failed to get IOHIDSystem registry entry")
            return nil
        }

        var unmanagedDict: Unmanaged<CFMutableDictionary>?
        defer { unmanagedDict?.release() }

        guard IORegistryEntryCreateCFProperties(
            entry,
            &unmanagedDict,
            kCFAllocatorDefault,
            0
        ) == KERN_SUCCESS else {
            Log.system.error("Failed to get IOHIDSystem properties")
            return nil
        }

        guard let dict = unmanagedDict?.takeUnretainedValue() else {
            Log.system.error("Failed to retain IOHIDSystem properties dictionary")
            return nil
        }

        let key = "HIDIdleTime" as CFString
        guard let value = CFDictionaryGetValue(dict, Unmanaged.passUnretained(key).toOpaque()) else {
            Log.system.error("HIDIdleTime key missing from IOHIDSystem properties")
            return nil
        }
        let number = unsafeBitCast(value, to: CFNumber.self)
        var nanoseconds: Int64 = 0

        guard CFNumberGetValue(number, .sInt64Type, &nanoseconds) else {
            Log.system.error("Failed to read HIDIdleTime value")
            return nil
        }

        return Double(nanoseconds) / Double(NSEC_PER_SEC)
    }

    /// Returns `true` if the user has been inactive for at least `seconds`.
    static func isUserInactive(for seconds: TimeInterval) -> Bool {
        (userInactiveSeconds() ?? 0) >= seconds
    }

    /// Returns `true` if the user has been inactive for at least `minutes`.
    static func isUserInactive(forMinutes minutes: Int) -> Bool {
        isUserInactive(for: TimeInterval(minutes) * Constants.minute)
    }
}
