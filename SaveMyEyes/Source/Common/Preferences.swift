//
//  File.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/25/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation

class Preferences{
    private static let selectedTimeIntervalKey = "SelectedTimeInterval";
    private static let selectedBreakTimeKey = "SelectedBreakTime";
    private static let isSoundEnabledKey = "IsSoundEnabled";
    
    private static let defaults = UserDefaults.standard
    
    /**
     Returns selected time interval index retrieved from the local storage
     
     returns `Int`:  Localy saved user selected time interval or `0` when there is no
     saved time interval
     */
    public static func getWorkIntervalIndexValue() -> Int {
        return defaults.integer(forKey: selectedTimeIntervalKey)
    }
    
    /**
     Returns selected break time index retrieved from the local storage
     
     returns `Int`:  Localy saved user selected break time index or `0` when there is
     no saved break time index
     */
    public static func getBreakIntervalIndexValue() -> Int {
        return defaults.integer(forKey: selectedBreakTimeKey)
    }
    
    /**
     Returns is sound enabled value retrieved from the local storage
     
     returns `Bool`:  Localy saved is sound enabled value or `false` when there is
     no saved is sound enabled value
     */
    public static func isSoundEnabled() -> Bool {
        return defaults.bool(forKey: isSoundEnabledKey)
    }
    
    public static func setWorkTimeIntervalIndexValue(_ value: Int) {
        defaults.set(value, forKey: selectedTimeIntervalKey)
    }
    
    public static func setBreakIntervalIndexValue(_ value: Int) {
        defaults.set(value, forKey: selectedBreakTimeKey)
    }
    
    public static func setSoundEnabled(_ value: Bool) {
        defaults.set(value, forKey: isSoundEnabledKey)
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
