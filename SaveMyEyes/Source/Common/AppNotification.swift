//
//  AppNotification.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation
import UserNotifications

struct AppNotification {
    static let defaultSound = UNNotificationSound.default
    static let withoutSound: UNNotificationSound? = nil

    private let title: String
    private let subtitle: String
    private let sound: UNNotificationSound?

    struct Action {
        static let pause = "pause.action"
    }

    struct Category {
        static let reminder = "sme.reminder"
    }

    init(title: String, subtitle: String, sound: UNNotificationSound? = defaultSound) {
        self.title = title
        self.subtitle = subtitle
        self.sound = sound
    }

    func content() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = sound
        content.categoryIdentifier = Category.reminder
        return content
    }
}

enum AppNotificationManager {
    private static let center = UNUserNotificationCenter.current()

    static func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error {
                Log.notifications.error("Authorization failed: \(error.localizedDescription)")
                completion(false, error)
            } else if !success {
                Log.notifications.error("Permission denied by user")
                let deniedError = NSError(
                    domain: "AppNotificationManager",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Notification permission denied"]
                )
                completion(false, deniedError)
            } else {
                Log.notifications.info("Permission granted")
                completion(true, nil)
            }
        }
    }

    static func send(_ notification: AppNotification) {
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notification.content(),
            trigger: nil
        )
        center.add(request)
    }

    static func sendSingle(_ notification: AppNotification) {
        center.removeAllDeliveredNotifications()
        send(notification)
    }

    static func removeAllNotifications() {
        center.removeAllDeliveredNotifications()
    }

    static func registerCategories() {
        let pause = UNNotificationAction(
            identifier: AppNotification.Action.pause,
            title: "Pause".localized,
            options: []
        )
        let category = UNNotificationCategory(
            identifier: AppNotification.Category.reminder,
            actions: [pause],
            intentIdentifiers: []
        )
        center.setNotificationCategories([category])
    }

    static func registerDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        center.delegate = delegate
    }

    static func removeDelegate() {
        center.delegate = nil
    }
}
