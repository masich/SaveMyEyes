//
//  AppDelegate.swift
//  SaveMyEyesLauncher
//
//  Created by Max Omelchenko on 28.06.2021.
//  Copyright © 2021 Max Omelchenko. All rights reserved.
//

import Cocoa

class AutoLauncherAppDelegate: NSObject, NSApplicationDelegate {
    struct Constants {
        static let mainAppBundleID = "com.masich.SaveMyEyes"
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == Constants.mainAppBundleID
        }
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            let applicationPathString = path as String
            let pathURL = URL(fileURLWithPath: applicationPathString, isDirectory: true)
            NSWorkspace.shared.openApplication(at: pathURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
    }
}
