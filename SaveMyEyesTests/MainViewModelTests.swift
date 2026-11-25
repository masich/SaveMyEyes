//
//  MainViewModelTests.swift
//  SaveMyEyesTests
//
//  Created by Maksym Omelchenko on 2026-11-24.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import UserNotifications
@testable import SaveMyEyes

@MainActor
final class MainViewModelTests: XCTestCase {
    private var vm: MainViewModel?

    override func setUp() {
        super.setUp()
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.remainingSeconds)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.isBreakTimeNow)
        UserDefaults.standard.synchronize()
    }

    override func tearDown() {
        vm?.stopTimer()
        vm = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.shouldTimerRun)
        UserDefaults.standard.synchronize()
        super.tearDown()
    }

    func testViewModelForwardsSnoozeSkipAndNotificationStatus() {
        let vm = MainViewModel(
            timerInterval: 1,
            allowedUserInactivityInterval: Constants.allowedUserInactivityInterval,
            terminateApp: {}
        )
        self.vm = vm
        vm.toggleBreakState()
        XCTAssertTrue(vm.isBreakTimeNow)

        vm.snoozeBreak()
        XCTAssertFalse(vm.isBreakTimeNow)
        XCTAssertEqual(vm.remainingSeconds, Defaults.snoozeMinutes * 60)

        vm.toggleBreakState()
        vm.skipBreak()
        XCTAssertFalse(vm.isBreakTimeNow)
        XCTAssertEqual(vm.remainingSeconds, vm.settings.workInterval * 60)

        // Stale snooze while already in Work must remain a no-op and stay paused
        vm.settings.shouldTimerRun = false
        let remainingWork = vm.remainingSeconds
        vm.snoozeBreak()
        XCTAssertFalse(vm.isBreakTimeNow)
        XCTAssertFalse(vm.settings.shouldTimerRun)
        XCTAssertEqual(vm.remainingSeconds, remainingWork)
    }

    func testRefreshNotificationAuthorizationStatusRunsWithoutCrashing() async {
        let vm = MainViewModel(
            timerInterval: 1,
            allowedUserInactivityInterval: Constants.allowedUserInactivityInterval,
            terminateApp: {}
        )
        self.vm = vm
        vm.refreshNotificationAuthorizationStatus()
        await Task.yield()
        // Should execute the status callback cleanly without mutating unexpected state
        XCTAssertFalse(vm.isBreakTimeNow)
    }

    func testNotificationCategoriesAndActionsAreDistinct() {
        XCTAssertNotEqual(AppNotification.Category.breakReminder, AppNotification.Category.workReminder)
        XCTAssertEqual(Set([AppNotification.Action.pause, AppNotification.Action.skip, AppNotification.Action.snooze]).count, 3)

        let breakContent = AppNotification(
            title: "Break",
            subtitle: "Sub",
            categoryIdentifier: AppNotification.Category.breakReminder
        ).content()
        XCTAssertEqual(breakContent.categoryIdentifier, AppNotification.Category.breakReminder)
    }
}
