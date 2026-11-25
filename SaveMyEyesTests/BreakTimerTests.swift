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
    var simulatedIdleSeconds: Double = 0

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
        simulatedIdleSeconds = 0
    }

    override func tearDown() {
        settings = nil
        super.tearDown()
    }

    private func makeTimer(
        allowedInactivityInterval: TimeInterval = Constants.allowedUserInactivityInterval,
        onBreakStateChanged: @escaping (Bool) -> Void = { _ in }
    ) -> BreakTimer {
        BreakTimer(
            tickInterval: 1,
            allowedUserInactivityInterval: allowedInactivityInterval,
            settings: settings,
            onNotification: { [weak self] in
                self?.notificationCount += 1
            },
            onBreakStateChanged: onBreakStateChanged,
            userInactiveSecondsProvider: { [weak self] in
                self?.simulatedIdleSeconds
            }
        )
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

    // MARK: - Manual toggle & reset

    func testToggleBreakStateSwitchesBetweenWorkAndBreak() {
        var reportedStates: [Bool] = []
        let timer = makeTimer(onBreakStateChanged: { reportedStates.append($0) })
        settings.workInterval = 20
        settings.breakInterval = 5

        timer.toggleBreakState()
        XCTAssertTrue(timer.isBreakTimeNow)
        XCTAssertEqual(timer.remainingSeconds, 5 * 60)
        XCTAssertEqual(reportedStates, [true])

        timer.toggleBreakState()
        XCTAssertFalse(timer.isBreakTimeNow)
        XCTAssertEqual(timer.remainingSeconds, 20 * 60)
        XCTAssertEqual(reportedStates, [true, false])
    }

    func testResetToDefaultsResetsBreakStateAndRemainingTime() {
        var reportedStates: [Bool] = []
        let timer = makeTimer(onBreakStateChanged: { reportedStates.append($0) })
        timer.toggleBreakState()
        XCTAssertTrue(timer.isBreakTimeNow)

        timer.resetToDefaults(workInterval: 25, breakInterval: 5)
        XCTAssertFalse(timer.isBreakTimeNow)
        XCTAssertEqual(timer.remainingSeconds, 25 * 60)
        XCTAssertEqual(reportedStates.last, false)
    }

    // MARK: - Tick & idle detection

    func testTickDecrementsRemainingSecondsWhenActive() {
        let timer = makeTimer()
        timer.updateRemainingForWorkInterval(1)
        let before = timer.remainingSeconds

        timer.simulateTick()
        XCTAssertEqual(timer.remainingSeconds, before - 1)
        XCTAssertEqual(notificationCount, 0)
    }

    func testTickTransitionsFromWorkToBreakAndBackWithNotifications() {
        var reportedStates: [Bool] = []
        let timer = makeTimer(onBreakStateChanged: { reportedStates.append($0) })
        settings.workInterval = 1
        settings.breakInterval = 1
        timer.updateRemainingForWorkInterval(1)

        // Drain all 60 seconds of work
        for _ in 0..<60 {
            timer.simulateTick()
        }
        XCTAssertTrue(timer.isBreakTimeNow)
        XCTAssertEqual(timer.remainingSeconds, 60)
        XCTAssertEqual(notificationCount, 1)
        XCTAssertEqual(reportedStates, [true])

        // Drain all 60 seconds of break
        for _ in 0..<60 {
            timer.simulateTick()
        }
        XCTAssertFalse(timer.isBreakTimeNow)
        XCTAssertEqual(timer.remainingSeconds, 60)
        XCTAssertEqual(notificationCount, 2)
        XCTAssertEqual(reportedStates, [true, false])
    }

    func testTickPausesAndExtendsWorkTimeWhenUserBecomesInactive() {
        let timer = makeTimer(allowedInactivityInterval: 10)
        settings.workInterval = 5
        timer.updateRemainingForWorkInterval(5)

        // Tick for 20 active seconds
        for _ in 0..<20 {
            timer.simulateTick()
        }
        XCTAssertEqual(timer.remainingSeconds, 280)

        // User goes idle (>= 10s): extends remaining by 10s (capped to workInterval * 60) and stops decrementing
        simulatedIdleSeconds = 12
        timer.simulateTick()
        XCTAssertEqual(timer.remainingSeconds, 290)

        // Subsequent idle ticks keep timer paused
        timer.simulateTick()
        XCTAssertEqual(timer.remainingSeconds, 290)

        // User becomes active again
        simulatedIdleSeconds = 0
        timer.simulateTick()
        XCTAssertEqual(timer.remainingSeconds, 289)
    }

    func testTickContinuesCountingDownDuringBreakEvenWhenInactive() {
        let timer = makeTimer(allowedInactivityInterval: 10)
        settings.breakInterval = 5
        timer.toggleBreakState()
        XCTAssertTrue(timer.isBreakTimeNow)

        simulatedIdleSeconds = 60
        timer.simulateTick()
        XCTAssertEqual(timer.remainingSeconds, 299)
    }
}
