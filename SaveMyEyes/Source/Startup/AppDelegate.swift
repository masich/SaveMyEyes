//
//  AppDelegate.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let viewModel = MainViewModel(workIntervals: Constants.workIntervals, breakIntervals: Constants.breakIntervals, timerInterval: Constants.timerInterval, allowedUserInactivityInterval: Constants.allowedUserInactivityInterval, terminateApp: AppDelegate.terminateApp)
        let view = MainView(mainViewModel: viewModel)
        
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
        AppNotification.makeNotificationRequest()
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    static func terminateApp() {
        NSApplication.shared.terminate(nil)
    }
}
