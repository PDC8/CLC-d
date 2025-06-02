//
//  NotificationManager.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/16/25.
//

import UserNotifications

class NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]) { _, _ in }
    }
    
    // Schedule notification for alarm time
    static func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "LeetCode Alarm!"
        content.body = "Solve a problem to dismiss"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = alarm.hour
        dateComponents.minute = alarm.minute

        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
