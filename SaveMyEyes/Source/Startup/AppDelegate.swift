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

    var panel: NSPanel!
    var statusItem: NSStatusItem!
    var viewModel: MainViewModel!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()
        setupViewModel()
        setupPanel()
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

    private func setupPanel() {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .popUpMenu
        panel.hidesOnDeactivate = true
        panel.isReleasedWhenClosed = false
        panel.backgroundColor = .clear
        panel.hasShadow = true

        let effectView = NSVisualEffectView()
        effectView.material = .menu
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = 12
        effectView.layer?.masksToBounds = true
        panel.contentView = effectView

        let hostingController = NSHostingController(
            rootView: MainView(viewModel: viewModel, settings: viewModel.settings)
        )
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        effectView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: effectView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: effectView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: effectView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: effectView.bottomAnchor),
        ])

        // Size the panel from the hosting view's fitting size
        hostingController.view.layoutSubtreeIfNeeded()
        let fittingSize = hostingController.view.fittingSize
        panel.setContentSize(fittingSize)

        self.panel = panel
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "StatusBarButtonImage")
        statusItem.button?.action = #selector(togglePanel)
        statusItem.button?.target = self
    }

    @objc private func togglePanel(_ sender: AnyObject?) {
        if panel.isVisible {
            closePanel()
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        guard let button = statusItem.button else { return }
        let screenRect = button.window?.frame ?? .zero

        let panelSize = panel.frame.size
        let x = screenRect.maxX - panelSize.width
        let y = screenRect.minY - panelSize.height

        panel.setFrameOrigin(NSPoint(x: x, y: y))
        NSApp.activate(ignoringOtherApps: true)
        panel.orderFrontRegardless()
    }

    private func closePanel() {
        panel.orderOut(nil)
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
