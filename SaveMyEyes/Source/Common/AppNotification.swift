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
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    func getNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default
        
        return content
    }
}

class AppNotificationManager {
    private static let notificationCenter = UNUserNotificationCenter.current()
    public static let defaultTimeToShow: TimeInterval = 5
    
    static func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications are allowed")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func send(_ notification: AppNotification,_ timeToShow: TimeInterval = defaultTimeToShow) {
        // Show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeToShow, repeats: false)
        let content = notification.getNotificationContent()
        // Choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add a request for this notification
        UNUserNotificationCenter.current().add(request)
    }
    
    /**
     Removes all AppNotifications from the NotificationCenter and sends a new one
     */
    static func sendSingle(_ notification: AppNotification,_ timeToShow: TimeInterval = defaultTimeToShow) {
        removeAllNotifications()
        send(notification, timeToShow)
    }
    
    static func removeAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
}
