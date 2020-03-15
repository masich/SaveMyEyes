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
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var mainViewModel: MainViewModel?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        mainViewModel = MainViewModel(workIntervals: Constants.workIntervals, breakIntervals: Constants.breakIntervals, timerInterval: Constants.minute, allowedUserInactivityInterval: Constants.allowedUserInactivityInterval, terminateApp: AppDelegate.terminateApp)
        let view = MainView(mainViewModel: mainViewModel!)
        
        // Create the popover
        let popover = NSPopover()
        
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: view)
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(togglePopover)
        }
        
        NSApp.activate(ignoringOtherApps: true)
        setupNotifications()
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        if self.popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        if let button = self.statusBarItem.button {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    private func closePopover() {
        self.popover.performClose(nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let category = response.notification.request.content.categoryIdentifier
        
        if category == AppNotification.Category.reminder {
            switch response.actionIdentifier {
            case AppNotification.Action.pause:
                mainViewModel?.pauseTimer()
                break
            default:
                break
            }
        }
        completionHandler()
    }
    
    private func setupNotifications() {
        AppNotificationManager.requestAuthorization()
        AppNotificationManager.removeAllNotifications()
        AppNotificationManager.registerDelegate(self)
        AppNotificationManager.registerCategories()
    }
    
    static func terminateApp() {
        NSApplication.shared.terminate(nil)
    }
}
