//
//  AnalysisService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 01/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import RealmSwift
import Proposer

public func analyzing(finish: (([Timetable], URL?) -> Void)? = nil) {
    
    guard let realm = try? Realm(), let userID = HiUserDefaults.userID.value else { return }
    
    let today = Date()
    let predicate = NSPredicate(format: "creator.id = %@", userID)
    
    var datas: [Timetable] = []
    
    // Feeds
    let feeds: [Feed] = FeedService.shared.fetchAll(withPredicate: predicate, fromRealm: realm).filter { $0.monthDay == today.hi.monthDay }
    datas.append(contentsOf: (feeds.map { $0 as Timetable }))
    
    let url = (feeds.flatMap { $0.story }.filter { $0.attachment != nil }.first?.attachment?.urlString).flatMap { URL(string: $0) }
    
    let localURL = url.map { CacheService.shared.filePath(forKey: $0.absoluteString) }.flatMap { URL(fileURLWithPath: $0) }
    
    // matter
    let matters: [Matter] = MatterService.shared.fetchAll(withPredicate: predicate, fromRealm: realm).filter { $0.monthDay == today.hi.monthDay }
    datas.append(contentsOf: (matters.map { $0 as Timetable }))
    
    /// connecting
    
    // photos
    var photos: [Photo] = []
    if PrivateResource.photos.isAuthorized && Defaults.connectPhotos {
        photos = fetchMoments(at: today)
        datas.append(contentsOf: (photos.map { $0 as Timetable }))
    }
    
    // calendar
    if PrivateResource.calendar.isAuthorized && Defaults.connectCalendar {
        let events = fetchEvents(at: today)
        datas.append(contentsOf: (events.map { $0 as Timetable }))
    }
    
    // Async at latest
    // reminders
    if PrivateResource.reminders.isAuthorized && Defaults.connectReminders {
        fetchReminders(at: today) { reminders in
            
            datas.append(contentsOf: (reminders.map { $0 as Timetable }))
           
            if localURL == nil, let asset = photos.first?.asset {
                
                // Asset URL can't be use in UNNotificationAttachment
                /*
                fetchURL(of: asset) { (url) in
                    finish?(datas, url)
                }
                 */
                let size = CGSize(width: 1024.0, height: 1024.0)
                fetchImage(with: asset, targetSize: size) { (image) in
                    guard let image = image else {
                        finish?(datas, nil)
                        return
                    }
                    let key = UUID().uuidString
                    PhotoCache.shared.store(image, forKey: key) {
                        let localURL = URL(fileURLWithPath: PhotoCache.shared.filePath(forKey: key))
                        finish?(datas, localURL)
                    }
                }
            } else {
                finish?(datas, localURL)
            }
        }
    } else {
        if localURL == nil, let asset = photos.first?.asset {
            fetchURL(of: asset) { (url) in
                finish?(datas, url)
            }
        } else {
            finish?(datas, localURL)
        }
    }
}
