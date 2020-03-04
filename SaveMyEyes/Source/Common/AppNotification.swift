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
        content.categoryIdentifier = Constants.reminderCategoryIdentifier
        
        return content
    }
}

class AppNotificationManager {
    private static let notificationCenter = UNUserNotificationCenter.current()
    
    static func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications are allowed")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func send(_ notification: AppNotification) {
        let content = notification.getNotificationContent()
        // Choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        // Add a request for this notification
        notificationCenter.add(request)
    }
    
    /**
     Removes all AppNotifications from the NotificationCenter and sends a new one
     */
    static func sendSingle(_ notification: AppNotification) {
        removeAllNotifications()
        send(notification)
    }
    
    static func removeAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    static func registerCategories() {
        let pause = UNNotificationAction(identifier: Constants.pauseActionIdentifier, title: "Pause", options: .destructive)
        let category = UNNotificationCategory(identifier: Constants.reminderCategoryIdentifier, actions: [pause], intentIdentifiers: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    static func registerDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        notificationCenter.delegate = delegate
    }
    
    static func removeDelegate() {
        notificationCenter.delegate = nil
    }
}
