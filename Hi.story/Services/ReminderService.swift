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

func fetchReminders(at date: Date = Date()) -> [Reminder] {
    
    var results: [Reminder] = []
    
    let store = EKEventStore()
    let predicate = store.predicateForReminders(in: nil)
    
    store.fetchReminders(matching: predicate) { (reminders) in
        reminders?.forEach({ (reminder) in
            
            // alarm? trigger date?
            if let dueDate = reminder.dueDateComponents?.date, dueDate.hi.monthDay == date.hi.monthDay {
                // due date
                results.append(Reminder(title: reminder.title, createdAt: dueDate.timeIntervalSince1970, isCompleted: reminder.isCompleted, completionDate: reminder.completionDate, dueDate: reminder.dueDateComponents?.date, alarm: reminder.alarms?.first?.absoluteDate))
            }
            
            if let completionDate = reminder.completionDate, completionDate.hi.monthDay == date.hi.monthDay {
                // complete date
                results.append(Reminder(title: reminder.title, createdAt: completionDate.timeIntervalSince1970, isCompleted: reminder.isCompleted, completionDate: reminder.completionDate, dueDate: reminder.dueDateComponents?.date, alarm: reminder.alarms?.first?.absoluteDate))
            }
        })
    }
    
    return results
}
