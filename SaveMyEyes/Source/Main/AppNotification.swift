//
//  Notification.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation
import UserNotifications

class AppNotification {
    private let title: String
    private let subtitle: String
    private let timeToShow: TimeInterval
    
    init(title: String, subtitle: String, timeToShow: TimeInterval = 5) {
        self.title = title
        self.subtitle = subtitle
        self.timeToShow = timeToShow
    }
    
    func send() {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeToShow, repeats: false)
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    static func makeNotificationRequest() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications are allowed")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
