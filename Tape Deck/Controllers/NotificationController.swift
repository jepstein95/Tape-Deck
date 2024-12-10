//
//  NotificationController.swift
//  Tape Deck
//
//  Created by Josh on 12/4/24.
//

import UserNotifications

class NotificationController {
    
    static func schedule(identifier: String, title: String, playAt: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Tape Deck Recording"
        content.subtitle = title
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: playAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancel(identifier: String) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}
