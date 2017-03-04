//
//  NotificationService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 01/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationService()
    
    func trigger(title: String, body: String, fileURL: URL? = nil, userInfo: [String: Any] = [:], requestIdentifier: String, delay: TimeInterval = 2.33, repeats: Bool = false) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = userInfo
        content.sound = UNNotificationSound.default()
        content.attachments = fileURL.flatMap { try? UNNotificationAttachment(identifier: "image", url: $0, options: nil) }.map { [$0] } ?? []
        //content.categoryIdentifier = "com.xspyhack.History.localNotification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: repeats)
        let request = UNNotificationRequest(identifier: "com.xspyhack.History." + requestIdentifier, content: content, trigger: trigger)
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let isBirthday = response.notification.request.content.userInfo["isBirthday"] as? Bool {
            print(isBirthday)
            
            // 跳转到 Home ，并且播放烟花或者五色纸片等效果
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    }
}
