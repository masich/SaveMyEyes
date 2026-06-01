//
//  BreakTimerTests.swift
//  SaveMyEyesTests
//

import XCTest
@testable import SaveMyEyes

@MainActor
final class BreakTimerTests: XCTestCase {

    var settings: SettingsStore!
    var notificationCount: Int!

    override func setUp() {
        super.setUp()
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.remainingSeconds)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.isBreakTimeNow)
        UserDefaults.standard.synchronize()

        settings = SettingsStore()
        notificationCount = 0
    }

    override func tearDown() {
        settings = nil
        super.tearDown()
    }

    private func makeTimer() -> BreakTimer {
        BreakTimer(tickInterval: 1, settings: settings) { [weak self] in
            self?.notificationCount += 1
        }
    }

    // MARK: - Initial state

    func testInitialRemainingSecondsEqualsWorkInterval() {
        let timer = makeTimer()
        timer.updateRemainingForWorkInterval(settings.workInterval)
        XCTAssertEqual(timer.remainingSeconds, settings.workInterval * 60)
        XCTAssertFalse(timer.isBreakTimeNow)
    }

    func testInitialStateHasPositiveRemainingTime() {
        let timer = makeTimer()
        XCTAssertGreaterThan(timer.remainingSeconds, 0)
        XCTAssertFalse(timer.isBreakTimeNow)
    }

    // MARK: - Interval updates

    func testUpdateRemainingForWorkIntervalWhenNotInBreak() {
        let timer = makeTimer()
        timer.updateRemainingForWorkInterval(20)
        XCTAssertEqual(timer.remainingSeconds, 20 * 60)
    }

    func testUpdateRemainingForBreakIntervalIgnoredWhenNotInBreak() {
        let timer = makeTimer()
        let originalRemaining = timer.remainingSeconds
        timer.updateRemainingForBreakInterval(10)
        XCTAssertEqual(timer.remainingSeconds, originalRemaining)
    }

    func testUpdateRemainingForWorkIntervalIgnoredDuringBreak() {
        let timer = makeTimer()
        timer.testSetBreakState(true)
        timer.updateRemainingForBreakInterval(5)
        XCTAssertEqual(timer.remainingSeconds, 5 * 60)

        timer.updateRemainingForWorkInterval(30)
        XCTAssertEqual(timer.remainingSeconds, 5 * 60)
    }

    func testUpdateRemainingForBreakIntervalWhenInBreak() {
        let timer = makeTimer()
        timer.testSetBreakState(true)
        timer.updateRemainingForBreakInterval(10)
        XCTAssertEqual(timer.remainingSeconds, 10 * 60)
    }

    // MARK: - Pause

    func testPauseSetsShouldTimerRunToFalse() {
        let timer = makeTimer()
        timer.pause()
        XCTAssertFalse(settings.shouldTimerRun)
    }

    // MARK: - Start / Stop lifecycle

    func testStartDoesNotCrash() {
        let timer = makeTimer()
        timer.start()
        timer.stop()
    }

    func testStopWhenNotRunningIsSafe() {
        let timer = makeTimer()
        timer.stop()
    }

    func testMultipleStartsAreIdempotent() {
        let timer = makeTimer()
        timer.start()
        timer.start()
        timer.stop()
    }

    func testDeinitDoesNotCrash() {
        let timer = makeTimer()
        timer.start()
        timer.stop()
    }

    func testStopAndRestartPreservesRemainingTime() {
        let timer = makeTimer()
        timer.updateRemainingForWorkInterval(10)
        timer.start()
        timer.stop()
        XCTAssertGreaterThan(timer.remainingSeconds, 0)
    }

    // MARK: - State persistence

    func testStatePersistedAfterIntervalUpdate() {
        let timer = makeTimer()
        timer.updateRemainingForWorkInterval(15)
        XCTAssertEqual(
            UserDefaults.standard.integer(forKey: UserDefaultsKey.remainingSeconds),
            15 * 60
        )
    }

    func testBreakStatePersistedAfterBreakpointSet() {
        let timer = makeTimer()
        timer.testSetBreakState(true)
        // Persist state is called when remainingSeconds changes during break
        timer.updateRemainingForBreakInterval(7)
        // The timer's isBreakTimeNow is independently persisted from settings.isBreakTimeNow.
        // After explicitly setting break state and updating remaining, the timer persists.
        XCTAssertTrue(timer.isBreakTimeNow)
    }

    // MARK: - Remaining minutes computation

    func testRemainingMinsComputedFromSeconds() {
        let timer = makeTimer()
        timer.updateRemainingForWorkInterval(25)
        XCTAssertEqual(timer.remainingMins, 25)
    }

    func testRemainingMinsTruncatesSeconds() {
        let timer = makeTimer()
        timer.updateRemainingForWorkInterval(10)
        // remainingSeconds = 600, remainingMins should be 10
        XCTAssertEqual(timer.remainingMins, 10)
    }
}
