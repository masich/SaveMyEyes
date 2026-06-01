//
//  SaveMyEyesTests.swift
//  SaveMyEyesTests
//
//  Created by Maksym Omelchenko on 5/30/26.
//  Copyright © 2026 Max Omelchenko. All rights reserved.
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
            UserDefaultsKey.launchAtLogin,
            UserDefaultsKey.remainingMinutes,
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

    // MARK: - Helper Bundle ID

    func testHelperBundleIDFormat() {
        XCTAssertTrue(Constants.helperBundleID.contains("."))
        XCTAssertFalse(Constants.helperBundleID.isEmpty)
    }
}
