//
//  NotificationManager.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 19/05/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("✅ Notification permission granted.")
            } else {
                print("❌ Notification permission denied.")
            }
        }
    }

    func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification:", error)
            } else {
                print("✅ Notification scheduled")
            }
        }
    }
}
