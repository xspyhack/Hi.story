//
//  ReminderService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import EventKit
import Hikit

struct Reminder: Timetable {
    let title: String
    let createdAt: TimeInterval
    let isCompleted: Bool
    let completionDate: Date?
    let dueDate: Date?
    let alarm: Date?
}

func fetchReminders(at date: Date = Date(), completion: @escaping ([Reminder]) -> Void) {
    
    var results: [Reminder] = []
    
    let store = EKEventStore()
    let calendars = store.calendars(for: .reminder)
    let predicate = store.predicateForReminders(in: calendars)
    
    store.fetchReminders(matching: predicate) { (reminders) in
        reminders?.forEach({ (reminder) in
            
            // alarm? trigger date?
            // 防止重复
            if let dueDate = reminder.dueDateComponents?.date, dueDate.hi.monthDay == date.hi.monthDay {
                // due date
                results.append(Reminder(title: reminder.title, createdAt: dueDate.timeIntervalSince1970, isCompleted: reminder.isCompleted, completionDate: reminder.completionDate, dueDate: reminder.dueDateComponents?.date, alarm: reminder.alarms?.first?.absoluteDate))
                
            } else if let completionDate = reminder.completionDate, completionDate.hi.monthDay == date.hi.monthDay {
                // complete date
                results.append(Reminder(title: reminder.title, createdAt: completionDate.timeIntervalSince1970, isCompleted: reminder.isCompleted, completionDate: reminder.completionDate, dueDate: reminder.dueDateComponents?.date, alarm: reminder.alarms?.first?.absoluteDate))
            }
        })
        
        completion(results)
    }
}
