//
//  SettingsStoreTests.swift
//  SaveMyEyesTests
//

import XCTest
@testable import SaveMyEyes

@MainActor
final class SettingsStoreTests: XCTestCase {

    var store: SettingsStore!

    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.shouldTimerRun)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.workInterval)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.breakInterval)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.isSoundEnabled)
        UserDefaults.standard.synchronize()
        store = SettingsStore()
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    // MARK: - Defaults

    func testInitialValuesMatchDefaults() {
        XCTAssertEqual(store.shouldTimerRun, Defaults.shouldTimerRun)
        XCTAssertEqual(store.isSoundEnabled, Defaults.isSoundEnabled)
        XCTAssertEqual(store.workInterval, Defaults.workInterval)
        XCTAssertEqual(store.breakInterval, Defaults.breakInterval)
        XCTAssertFalse(store.isBreakTimeNow)
    }

    // MARK: - Persistence round-trips

    func testWorkIntervalPersists() {
        store.workInterval = 30
        XCTAssertEqual(UserDefaults.standard.integer(forKey: UserDefaultsKey.workInterval), 30)
    }

    func testBreakIntervalPersists() {
        store.breakInterval = 5
        XCTAssertEqual(UserDefaults.standard.integer(forKey: UserDefaultsKey.breakInterval), 5)
    }

    func testIsSoundEnabledPersists() {
        store.isSoundEnabled = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: UserDefaultsKey.isSoundEnabled))
    }

    func testShouldTimerRunPersists() {
        store.shouldTimerRun = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultsKey.shouldTimerRun))
    }

    func testLaunchAtLoginToggle() {
        store.launchAtLogin = true
        XCTAssertTrue(store.launchAtLogin)
        store.launchAtLogin = false
        XCTAssertFalse(store.launchAtLogin)
    }

    // MARK: - Reset to defaults

    func testResetToDefaultsRestoresWorkInterval() {
        store.workInterval = 45
        store.resetToDefaults()
        XCTAssertEqual(store.workInterval, Defaults.workInterval)
    }

    func testResetToDefaultsRestoresBreakInterval() {
        store.breakInterval = 10
        store.resetToDefaults()
        XCTAssertEqual(store.breakInterval, Defaults.breakInterval)
    }

    func testResetToDefaultsRestoresIsSoundEnabled() {
        store.isSoundEnabled = false
        store.resetToDefaults()
        XCTAssertEqual(store.isSoundEnabled, Defaults.isSoundEnabled)
    }

    func testResetToDefaultsRestoresShouldTimerRun() {
        store.shouldTimerRun = true
        store.resetToDefaults()
        XCTAssertEqual(store.shouldTimerRun, Defaults.shouldTimerRun)
    }

    // MARK: - Interval change callbacks

    func testWorkIntervalCallbackFiresWhenNotInBreak() {
        var callbackPair: (Int, Int)?
        store.onWorkIntervalChanged = { callbackPair = ($0, $1) }

        store.workInterval = 30
        XCTAssertEqual(callbackPair?.0, Defaults.workInterval)
        XCTAssertEqual(callbackPair?.1, 30)
    }

    func testWorkIntervalCallbackDoesNotFireDuringBreak() {
        store.isBreakTimeNow = true
        var callbackPair: (Int, Int)?
        store.onWorkIntervalChanged = { callbackPair = ($0, $1) }

        store.workInterval = 30
        XCTAssertNil(callbackPair)
    }

    func testBreakIntervalCallbackFiresWhenInBreak() {
        store.isBreakTimeNow = true
        var callbackPair: (Int, Int)?
        store.onBreakIntervalChanged = { callbackPair = ($0, $1) }

        store.breakInterval = 7
        XCTAssertEqual(callbackPair?.0, Defaults.breakInterval)
        XCTAssertEqual(callbackPair?.1, 7)
    }

    func testBreakIntervalCallbackDoesNotFireWhenNotInBreak() {
        var callbackPair: (Int, Int)?
        store.onBreakIntervalChanged = { callbackPair = ($0, $1) }

        store.breakInterval = 7
        XCTAssertNil(callbackPair)
    }

    // MARK: - isBreakTimeNow

    func testIsBreakTimeNowStartsFalse() {
        XCTAssertFalse(store.isBreakTimeNow)
    }

    func testIsBreakTimeNowCanBeSet() {
        store.isBreakTimeNow = true
        XCTAssertTrue(store.isBreakTimeNow)
    }

    // MARK: - Timer run state callback

    func testOnTimerRunStateChangedFiresWhenToggled() {
        var states: [Bool] = []
        store.onTimerRunStateChanged = { states.append($0) }

        store.shouldTimerRun = true
        store.shouldTimerRun = false
        XCTAssertEqual(states, [true, false])
    }
}
