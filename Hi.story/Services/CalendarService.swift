//
//  CalendarService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import EventKit
import Hikit

struct Event: Timetable {
    let title: String
    let createdAt: TimeInterval
    let occurrenceDate: Date?
    let alarm: Date?
}

func fetchEvents(at date: Date = Date()) -> [Event] {
    
    var results: [Event] = []
    
    let startDate = Date(timeIntervalSince1970: 0)
    
    let store = EKEventStore()
    let predicate = store.predicateForEvents(withStart: startDate, end: date, calendars: nil)
    let events = store.events(matching: predicate)
    
    events.forEach { (event) in
        if event.occurrenceDate.hi.monthDay == date.hi.monthDay {
            results.append(Event(title: event.title, createdAt: event.occurrenceDate.timeIntervalSince1970, occurrenceDate: event.occurrenceDate, alarm: event.alarms?.first?.absoluteDate))
        }
    }
    
    return results
}
