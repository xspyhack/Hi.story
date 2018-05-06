//
//  CalendarService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import EventKit

public struct Event: Timetable {
    public let title: String
    public let createdAt: TimeInterval
    public let occurrenceDate: Date?
    public let alarm: Date?
}

public func fetchEvents(at date: Date = Date()) -> [Event] {
    
    var results: [Event] = []
    
    // 默认生日开始， 最多 45 年前
    // let startDate = Defaults.birthday.map { Date(timeIntervalSince1970: $0) } ?? 2.hi.years.ago
    // 因为如果不舍 repeats 的话，会被自动删除，所以多年也是没有什么意义的
    let startDate = 2.hi.years.ago

    let store = EKEventStore()
    //
    let predicate = store.predicateForEvents(withStart: startDate, end: date, calendars: store.calendars(for: .event).filter { $0.source.sourceType != .subscribed }) // 去掉 中国节假日
    let events = store.events(matching: predicate)
    
    events.forEach { (event) in
        if event.occurrenceDate.hi.monthDay == date.hi.monthDay {
            results.append(Event(title: event.title, createdAt: event.occurrenceDate.timeIntervalSince1970, occurrenceDate: event.occurrenceDate, alarm: event.alarms?.first?.absoluteDate))
        }
    }
   
    return results
}
