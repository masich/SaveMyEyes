//
//  AppNotification.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko on 2020-02-24.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UserNotifications

struct AppNotification {
    static let defaultSound = UNNotificationSound.default
    static let withoutSound: UNNotificationSound? = nil

    private let title: String
    private let subtitle: String
    private let sound: UNNotificationSound?
    private let categoryIdentifier: String

    struct Action {
        static let pause = "pause.action"
        static let skip = "skip.action"
        static let snooze = "snooze.action"
    }

    struct Category {
        static let breakReminder = "sme.break.reminder"
        static let workReminder = "sme.work.reminder"
    }

    init(
        title: String,
        subtitle: String,
        sound: UNNotificationSound? = defaultSound,
        categoryIdentifier: String = Category.breakReminder
    ) {
        self.title = title
        self.subtitle = subtitle
        self.sound = sound
        self.categoryIdentifier = categoryIdentifier
    }

    func content() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = sound
        content.categoryIdentifier = categoryIdentifier
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

    static func getAuthorizationStatus(completion: @escaping @Sendable (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    private static func send(_ notification: AppNotification) {
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notification.content(),
            trigger: nil
        )
        center.add(request)
    }

    static func sendSingle(_ notification: AppNotification) {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        send(notification)
    }

    static func removeAllNotifications() {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }

    static func registerCategories() {
        let snooze = UNNotificationAction(
            identifier: AppNotification.Action.snooze,
            title: "Snooze 5 min".localized,
            options: []
        )
        let skip = UNNotificationAction(
            identifier: AppNotification.Action.skip,
            title: "Skip".localized,
            options: []
        )
        let pause = UNNotificationAction(
            identifier: AppNotification.Action.pause,
            title: "Pause".localized,
            options: []
        )
        let breakCategory = UNNotificationCategory(
            identifier: AppNotification.Category.breakReminder,
            actions: [snooze, skip, pause],
            intentIdentifiers: []
        )
        let workCategory = UNNotificationCategory(
            identifier: AppNotification.Category.workReminder,
            actions: [pause],
            intentIdentifiers: []
        )
        center.setNotificationCategories([breakCategory, workCategory])
    }

    static func registerDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        center.delegate = delegate
    }
}
