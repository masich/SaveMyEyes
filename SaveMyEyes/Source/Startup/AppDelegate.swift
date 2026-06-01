//
//  AppDelegate.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Cocoa
import SwiftUI
import UserNotifications

@MainActor
@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusItem: NSStatusItem!
    var viewModel: MainViewModel!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()
        setupViewModel()
        setupPopover()
        setupStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Timer state is already persisted via UserDefaults in BreakTimer
        // No additional cleanup needed
    }

    // MARK: - Setup

    private func setupNotifications() {
        AppNotificationManager.registerCategories()
        AppNotificationManager.registerDelegate(self)
        AppNotificationManager.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if let error {
                    Log.notificationError("Authorization error: \(error.localizedDescription)")
                } else if !success {
                    Log.notificationWarning("Notifications not authorized")
                }
            }
        }
    }

    private func setupViewModel() {
        viewModel = MainViewModel(
            timerInterval: 1, // tick every second for smooth UI updates
            allowedUserInactivityInterval: Constants.allowedUserInactivityInterval,
            terminateApp: { NSApp.terminate(nil) }
        )
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MainView(viewModel: viewModel, settings: viewModel.settings)
        )
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "StatusBarButtonImage")
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.target = self
    }

    // MARK: - Actions

    @objc private func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closePopover() {
        popover.performClose(nil)
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let category = response.notification.request.content.categoryIdentifier

        if category == AppNotification.Category.reminder {
            switch response.actionIdentifier {
            case AppNotification.Action.pause:
                viewModel.pauseTimer()
            default:
                break
            }
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }
}
