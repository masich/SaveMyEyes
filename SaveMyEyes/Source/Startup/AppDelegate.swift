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

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    var popover: NSPopover!
    var statusItem: NSStatusItem!
    var viewModel: MainViewModel!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()
        setupViewModel()
        setupPopover()
        setupStatusItem()
    }

    private func setupNotifications() {
        AppNotificationManager.registerCategories()
        AppNotificationManager.registerDelegate(self)
        AppNotificationManager.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if let error {
                    Log.notifications.error("Authorization error: \(error.localizedDescription)")
                } else if !success {
                    Log.notifications.warning("Notifications not authorized")
                }
            }
        }
    }

    private func setupViewModel() {
        viewModel = MainViewModel(
            timerInterval: 1,
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

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let category = response.notification.request.content.categoryIdentifier
        if category == AppNotification.Category.reminder {
            switch response.actionIdentifier {
            case AppNotification.Action.pause:
                Task { @MainActor in
                    self.viewModel.pauseTimer()
                }
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
