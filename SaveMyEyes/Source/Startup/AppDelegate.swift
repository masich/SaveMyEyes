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

    var statusItem: NSStatusItem!
    var viewModel: MainViewModel!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()
        setupViewModel()
        setupStatusItem()
        createPopover()
    }

    // MARK: - Notifications

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

    // MARK: - View Model

    private func setupViewModel() {
        viewModel = MainViewModel(
            timerInterval: 1,
            allowedUserInactivityInterval: Constants.allowedUserInactivityInterval,
            terminateApp: { NSApp.terminate(nil) }
        )
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "StatusBarButtonImage")
        statusItem.button?.action = #selector(togglePopover(_:))
        statusItem.button?.target = self
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
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    private func showPopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        createPopover()

        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        CATransaction.commit()

        popover.contentViewController?.view.window?.makeKey()
    }

    private func closePopover(_ sender: AnyObject?) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        popover.performClose(sender)
        CATransaction.commit()
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
