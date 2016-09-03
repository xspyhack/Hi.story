//
//  NSDate+Hi.swift
//  Hi.kit
//

//  Created by bl4ckra1sond3tre on 10/9/15.
//  Copyright © 2015 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

private let d_DAY: Int = 86400

public extension Hi where Base: NSDate {
    
    public var timestamp: String {
        Date.formatter.dateFormat = NSDate.timestampFormatString
        return Date.formatter.stringFromDate(base)
    }
    
    public var monthDayYear: String {
        Date.formatter.dateFormat = NSDate.mdyDateFormatString
        return Date.formatter.stringFromDate(base)
    }
    
    public var yearMonthDay: String {
        Date.formatter.dateFormat = "yyyy/MM/dd"
        return Date.formatter.stringFromDate(base)
    }
    
    public var year: String {
        Date.formatter.dateFormat = "yyyy"
        return Date.formatter.stringFromDate(base)
    }
    
    public var month: String {
        Date.formatter.dateFormat = "MM"
        return Date.formatter.stringFromDate(base)
    }
    
    public var day: String {
        Date.formatter.dateFormat = "dd"
        return Date.formatter.stringFromDate(base)
    }
    
    public var hour: String {
        Date.formatter.dateFormat = "HH"
        return Date.formatter.stringFromDate(base)
    }
    
    public var minute: String {
        Date.formatter.dateFormat = "mm"
        return Date.formatter.stringFromDate(base)
    }
    
    public var time: String {
        Date.formatter.dateFormat = "HH:mm"
        return Date.formatter.stringFromDate(base)
    }
    
    public var weekIndex: Int {
        return NSDate().hi.weekOfYear()
    }
    
    public var weekday: String {
        switch weekdayIndex() {
        case 0:
            return "Sunday"
        case 1:
            return "Monday"
        case 2:
            return "Tuesday"
        case 3:
            return "Wednesday"
        case 4:
            return "Thursday"
        case 5:
            return "Friday"
        case 6:
            return "Saturday"
        default:
            return "Unknow"
        }
    }
    
    public func days(withDate comparingDate: NSDate) -> Int {
        
        return NSDate.hi.daysOffset(between: base, with: comparingDate)
    }
    
    // @returns 0...6
    // `0`: Sunday and `6`: Saturday
    public func weekdayIndex() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Calendar, .Weekday, .WeekdayOrdinal], fromDate: base)
        return components.weekday - 1
    }
    
    public func weekOfYear() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Calendar, .WeekOfYear], fromDate: base)
        return components.weekOfYear
    }
    
    public func dateByAddingDays(days: Int) -> NSDate {
        let timeInterval = base.timeIntervalSinceReferenceDate + NSTimeInterval(d_DAY * days)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateWithDaysFromNow(days: Int) -> NSDate {
        return NSDate().hi.dateByAddingDays(days)
    }
    
    public func dateBySubtractingDays(days: Int) -> NSDate {
        return dateByAddingDays(days * -1)
    }
    
    public func dateWithDaysBeforeNow(days: Int) -> NSDate {
        return NSDate().hi.dateBySubtractingDays(days)
    }
}

public extension X where Base: NSDate {
    
    public static func daysOffset(between startDate: NSDate, with endDate: NSDate) -> Int {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        let comps = gregorian?.components(.Day, fromDate: startDate, toDate: endDate, options: .WrapComponents)
        return (comps?.day ?? 0)
    }
    
    public static func dateFromString(aString: String, withFormat format: String = NSDate.timestampFormatString) -> NSDate? {
        let inputFormatter = NSDateFormatter()
        inputFormatter.dateFormat = format
        
        return inputFormatter.dateFromString(aString)
    }
}

private struct Date {
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US") // No localized string
        return formatter
    }()
}

public extension NSDate {
    
    private struct Date {
        static let formatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US") // No localized string
            return formatter
        }()
    }
    
    private static let dateFormatString = "yyyy-MM-dd"
    private static let mdyDateFormatString = "MMM dd, yyy"
    private static let timeFormatString = "HH:mm:ss"
    private static let timestampFormatString = "yyyy-MM-dd'T'HH:mm:ssZ"

}
