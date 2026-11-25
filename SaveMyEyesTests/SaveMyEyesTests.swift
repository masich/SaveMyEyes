//
//  SaveMyEyesTests.swift
//  SaveMyEyesTests
//
//  Created by Maksym Omelchenko on 2026-05-30.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import SaveMyEyes

@MainActor
final class SaveMyEyesTests: XCTestCase {

    func testUserDefaultsKeysAreUnique() {
        let keys = [
            UserDefaultsKey.shouldTimerRun,
            UserDefaultsKey.workInterval,
            UserDefaultsKey.breakInterval,
            UserDefaultsKey.isSoundEnabled,
            UserDefaultsKey.remainingSeconds,
            UserDefaultsKey.isBreakTimeNow,
        ]
        let uniqueKeys = Set(keys)
        XCTAssertEqual(keys.count, uniqueKeys.count, "UserDefaults keys must be unique")
    }

    func testDefaultsHaveValidRanges() {
        XCTAssertTrue(Constants.workIntervalRange.contains(Defaults.workInterval))
        XCTAssertTrue(Constants.breakIntervalRange.contains(Defaults.breakInterval))
    }

    func testWorkIntervalRangeIsValid() {
        XCTAssertLessThan(Constants.workIntervalRange.lowerBound, Constants.workIntervalRange.upperBound)
    }

    func testBreakIntervalRangeIsValid() {
        XCTAssertLessThan(Constants.breakIntervalRange.lowerBound, Constants.breakIntervalRange.upperBound)
    }

    func testDefaultsWorkIntervalIsPositive() {
        XCTAssertGreaterThan(Defaults.workInterval, 0)
    }

    func testDefaultsBreakIntervalIsPositive() {
        XCTAssertGreaterThan(Defaults.breakInterval, 0)
    }

    func testMinuteConstantIs60Seconds() {
        XCTAssertEqual(Constants.minute, 60)
    }

    // MARK: - Duration formatting

    func testDurationStringFormatsMinutesAndSeconds() {
        XCTAssertEqual(540.asDurationString, "9:00")
        XCTAssertEqual(125.asDurationString, "2:05")
        XCTAssertEqual(60.asDurationString, "1:00")
        XCTAssertEqual(59.asDurationString, "0:59")
        XCTAssertEqual(0.asDurationString, "0:00")
    }

    func testPaddedDurationStringFormatsWithLeadingZeros() {
        XCTAssertEqual(540.asPaddedDurationString, "09:00")
        XCTAssertEqual(125.asPaddedDurationString, "02:05")
        XCTAssertEqual(60.asPaddedDurationString, "01:00")
        XCTAssertEqual(59.asPaddedDurationString, "00:59")
        XCTAssertEqual(1500.asPaddedDurationString, "25:00")
    }

    // MARK: - Localization

    func testAllLocalizationsHaveMatchingKeys() throws {
        let localizations = ["en", "de", "es", "fr", "it", "pl", "ro", "uk"]
        let englishURL = try XCTUnwrap(
            Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en")
        )
        let englishDict = try XCTUnwrap(NSDictionary(contentsOf: englishURL) as? [String: String])
        let expectedKeys = Set(englishDict.keys)
        let requiredNewKeys = [
            "Notifications are disabled. Enable them in System Settings to receive break reminders.",
            "Open Settings",
            "Snooze 5 min",
            "Skip",
            "Resume",
        ]
        for key in requiredNewKeys {
            XCTAssertTrue(expectedKeys.contains(key), "Missing required key in English localization: \(key)")
        }

        for locale in localizations {
            let url = try XCTUnwrap(
                Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: locale),
                "Missing Localizable.strings for locale: \(locale)"
            )
            let dict = try XCTUnwrap(NSDictionary(contentsOf: url) as? [String: String])
            XCTAssertEqual(Set(dict.keys), expectedKeys, "Localization keys mismatch for locale: \(locale)")

            for (key, value) in dict {
                XCTAssertFalse(
                    value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "Empty translation for '\(key)' in locale: \(locale)"
                )
            }
            let launchAtLogin = try XCTUnwrap(dict["Launch at login"])
            XCTAssertFalse(
                launchAtLogin.contains("\n"),
                "'Launch at login' should not contain hard line break in locale: \(locale)"
            )
        }
    }

    // MARK: - App Delegate & Status Item

    func testAppDelegateStatusItemProperties() {
        guard let delegate = NSApp.delegate as? AppDelegate,
              let statusItem = delegate.statusItem else {
            return
        }

        XCTAssertEqual(statusItem.length, NSStatusItem.squareLength)
        XCTAssertEqual(statusItem.button?.imagePosition, .imageOnly)
        XCTAssertNotNil(statusItem.button?.image)
    }
}
