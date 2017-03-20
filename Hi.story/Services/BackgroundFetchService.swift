//
//  BackgroundFetchService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 20/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

class BackgroundFetchService {
    
    static let shared = BackgroundFetchService()
    
    func fetch(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // 最多只有 30 秒时间处理，超过的话后果很严重
        // When this method is called, your app has up to 30 seconds of wall-clock time to perform the download operation and call the specified completion handler block
        //  If your app takes a long time to call the completion handler, it may be given fewer future opportunities to fetch data in the future.
        // via https://developer.apple.com/reference/uikit/uiapplicationdelegate/1623125-application https://www.objc.io/issues/5-ios7/multitasking/
        print("background fetch begin: \(Date())")
        
        // 给 25s，如果不完成，那就直接执行 completionHandler，确保在 30s 内
        let completionTask = delay(25.0) {
            completionHandler(.noData)
        }
        
        let today = Date().hi.yearMonthDay
        
        guard Defaults.latestAnalyingDate != today, Defaults.notificationsEnabled else {
            cancel(completionTask) // cancel
            completionHandler(.failed)
            return
        }
        
        if (Defaults.birthday.flatMap { Date(timeIntervalSince1970: $0) })?.hi.monthDay == Date().hi.monthDay {
            // trigger notification
            let body = "Happy birthday to you!"
            let title = HiUserDefaults.nickname.value.map { "Hi, \($0)" } ?? "Hi, Master"
            
            NotificationService.shared.trigger(title: title, body: body, userInfo: ["isBirthday": true], requestIdentifier: today)
            
            cancel(completionTask) // cancel
            
            completionHandler(.newData)
            return
        }
        
        analyzing { datas, url in
            
            Defaults.latestAnalyingDate = today
            
            if !datas.isEmpty {
                // trigger notification
                let body = datas.count == 1 ? "There are some memories about you in this day of history." : "There are \(datas.count) memories about you in this day of history."
                let title = HiUserDefaults.nickname.value.map { "Hi, \($0)" } ?? "Hi, Master"
                
                NotificationService.shared.trigger(title: title, body: body, fileURL: url, requestIdentifier: today)
                
                cancel(completionTask) // cancel
                
                completionHandler(.newData)
            } else {
                cancel(completionTask) // cancel
                
                completionHandler(.noData)
            }
        }
    }
}
