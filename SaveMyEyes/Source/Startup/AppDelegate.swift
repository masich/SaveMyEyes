//
//  AppDelegate.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko on 2020-02-24.
//  SPDX-License-Identifier: Apache-2.0
//

import Cocoa
import SwiftUI
import UserNotifications

@NSApplicationMain
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    var statusItem: NSStatusItem!
    var viewModel: MainViewModel!
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupViewModel()
        setupNotifications()
        createPopover()
        setupStatusItem()
        setupWakeObserver()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        viewModel.persistTimerState()
    }

    // MARK: - Notifications

    private func setupNotifications() {
        AppNotificationManager.registerCategories()
        AppNotificationManager.registerDelegate(self)
        AppNotificationManager.requestAuthorization { [weak self] success, error in
            Task { @MainActor [weak self] in
                if let error {
                    Log.notifications.error("Authorization error: \(error.localizedDescription)")
                } else if !success {
                    Log.notifications.warning("Notifications not authorized")
                }
                self?.viewModel.refreshNotificationAuthorizationStatus()
            }
        }
    }

    // MARK: - Wake Observer

    private func setupWakeObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.viewModel.handleWake()
            }
        }
    }

    // MARK: - View Model

    private func setupViewModel() {
        viewModel = MainViewModel(
            timerInterval: 1.0,
            allowedUserInactivityInterval: Constants.allowedUserInactivityInterval,
            terminateApp: { NSApp.terminate(nil) }
        )
        if viewModel.settings.shouldTimerRun {
            viewModel.startTimer()
        }
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(named: "StatusBarButtonImage")
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem.button?.action = #selector(handleStatusItemClick(_:))
        statusItem.button?.target = self

        viewModel.onTimerRunStateChanged = { [weak self] _ in
            self?.updateStatusButton()
        }
        updateStatusButton()
    }

    /// Updates the status bar icon opacity based on timer run state.
    private func updateStatusButton() {
        guard let button = statusItem.button else { return }
        button.contentTintColor = nil
        button.alphaValue = viewModel.settings.shouldTimerRun ? 1.0 : 0.35
        button.imagePosition = .imageOnly
    }

    @objc private func handleStatusItemClick(_ sender: AnyObject?) {
        let event = NSApp.currentEvent
        let isRightClick = event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true
        if isRightClick {
            if popover?.isShown == true {
                closePopover(sender)
            }
            showContextMenu()
        } else {
            togglePopover(sender)
        }
    }

    private func showContextMenu() {
        guard let button = statusItem.button else { return }

        let menu = NSMenu()
        let statusLabel = viewModel.isBreakTimeNow ? "On break".localized : "Working".localized
        let headerItem = NSMenuItem(
            title: "\(statusLabel) — \(viewModel.remainingSeconds.asDurationString)",
            action: nil,
            keyEquivalent: ""
        )
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        menu.addItem(.separator())

        let runToggleTitle = viewModel.settings.shouldTimerRun ? "Pause".localized : "Resume".localized
        let runToggleItem = NSMenuItem(
            title: runToggleTitle,
            action: #selector(toggleTimerFromMenu),
            keyEquivalent: ""
        )
        runToggleItem.target = self
        menu.addItem(runToggleItem)

        let switchTitle = viewModel.isBreakTimeNow ? "Switch to work".localized : "Switch to break".localized
        let switchItem = NSMenuItem(
            title: switchTitle,
            action: #selector(toggleBreakStateFromMenu),
            keyEquivalent: ""
        )
        switchItem.target = self
        menu.addItem(switchItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit".localized,
            action: #selector(quitFromMenu),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        button.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func toggleTimerFromMenu() {
        viewModel.settings.shouldTimerRun.toggle()
    }

    @objc private func toggleBreakStateFromMenu() {
        viewModel.toggleBreakState()
    }

    @objc private func quitFromMenu() {
        viewModel.quit()
    }

    // MARK: - Popover

    private func createPopover() {
        let popover = NSPopover()
        popover.behavior = .transient

        let hostingController = NSHostingController(
            rootView: MainView(viewModel: viewModel, settings: viewModel.settings)
        )
        hostingController.sizingOptions = [.preferredContentSize]
        popover.contentViewController = hostingController
        popover.contentSize = hostingController.preferredContentSize

        self.popover = popover
    }

    // MARK: - Popover Toggle

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let popover = popover else { return }
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    func showPopover(_ sender: AnyObject?) {
        guard let popover = popover, let button = statusItem.button else { return }

        viewModel.settings.syncLaunchAtLoginFromSystem()
        viewModel.refreshNotificationAuthorizationStatus()

        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        CATransaction.commit()

        popover.contentViewController?.view.window?.makeKey()
    }

    func closePopover(_ sender: AnyObject?) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        popover?.performClose(sender)
        CATransaction.commit()
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let category = response.notification.request.content.categoryIdentifier
        let actionIdentifier = response.actionIdentifier
        if category == AppNotification.Category.breakReminder || category == AppNotification.Category.workReminder {
            switch actionIdentifier {
            case AppNotification.Action.pause:
                Task { @MainActor in
                    self.viewModel.pauseTimer()
                    completionHandler()
                }
                return
            case AppNotification.Action.skip:
                Task { @MainActor in
                    self.viewModel.skipBreak()
                    completionHandler()
                }
                return
            case AppNotification.Action.snooze:
                Task { @MainActor in
                    self.viewModel.snoozeBreak()
                    completionHandler()
                }
                return
            default:
                break
            }
        }
        completionHandler()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .badge, .sound])
    }
}
