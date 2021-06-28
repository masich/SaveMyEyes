//
//  main.swift
//  SaveMyEyesLauncher
//
//  Created by Max Omelchenko on 28.06.2021.
//  Copyright © 2021 Max Omelchenko. All rights reserved.
//

import Cocoa

let delegate = AutoLauncherAppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
