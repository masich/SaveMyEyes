//
//  File.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/25/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

class Preferences{
    private static let defaults = UserDefaults.standard
    
    /**
     Returns selected time interval index retrieved from the local storage
     
     returns `Int?`:  Localy saved user selected time interval or nil when there is no
     saved time interval
     */
    public static func getWorkIntervalIndexValue() -> Int {
        return defaults.integer(forKey: "SelectedTimeInterval")
    }
    
    /**
     Returns selected break time  index retrieved from the local storage
     
     returns `Int?`:  Localy saved user selected break time index or nil when there is
     no saved break time index
     */
    public static func getBreakIntervalIndexValue() -> Int {
        return defaults.integer(forKey: "SelectedBreakTime")
    }
    
    public static func setWorkTimeIntervalIndexValue(_ value: Int) {
        defaults.set(value, forKey: "SelectedTimeInterval")
    }
    
    public static func setBreakIntervalIndexValue(_ value: Int) {
        defaults.set(value, forKey: "SelectedBreakTime")
    }
}

class System {
    /**
     Returns number of seconds since system became idle
     
     returns: `Double?`: System idle time in seconds or nil when unable to retrieve it
     */
    public static func getUserInactiveSeconds() -> Double? {
        var iterator: io_iterator_t = 0
        defer { IOObjectRelease(iterator) }
        guard IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iterator) == KERN_SUCCESS else { return nil }
        
        let entry: io_registry_entry_t = IOIteratorNext(iterator)
        defer { IOObjectRelease(entry) }
        guard entry != 0 else { return nil }
        
        var unmanagedDict: Unmanaged<CFMutableDictionary>?
        defer { unmanagedDict?.release() }
        guard IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS else { return nil }
        guard let dict = unmanagedDict?.takeUnretainedValue() else { return nil }
        
        let key: CFString = "HIDIdleTime" as CFString
        let value = CFDictionaryGetValue(dict, Unmanaged.passUnretained(key).toOpaque())
        let number: CFNumber = unsafeBitCast(value, to: CFNumber.self)
        var nanoseconds: Int64 = 0
        guard CFNumberGetValue(number, CFNumberType.sInt64Type, &nanoseconds) else { return nil }
        let interval = Double(nanoseconds) / Double(NSEC_PER_SEC)
        
        return interval
    }
    
    /**
     Checks if user is inactive for last `forTimeInterval` seconds
     */
    public static func isUserInactive(forTimeInterval: TimeInterval) -> Bool {
        return (getUserInactiveSeconds() ?? 0) >= forTimeInterval
    }
    
    public static func isUserInactive(forMinutes: Int) -> Bool {
        return isUserInactive(forTimeInterval: TimeInterval(forMinutes) * Constants.minute)
    }
}
