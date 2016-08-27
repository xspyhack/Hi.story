//
//  NSDate+Hi.swift
//  Hi.kit
//

//  Created by bl4ckra1sond3tre on 10/9/15.
//  Copyright © 2015 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

private let d_DAY: Int = 86400

public extension NSDate where Base: Hi {
    
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
    
    public class func hi_dateFromString(aString: String, withFormat format: String = NSDate.timestampFormatString) -> NSDate? {
        let inputFormatter = NSDateFormatter()
        inputFormatter.dateFormat = format
        inputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        
        return inputFormatter.dateFromString(aString)
    }
    
    public var monthDayYear: String {
        Date.formatter.dateFormat = NSDate.mdyDateFormatString
        return Date.formatter.stringFromDate(self)
    }
    
    public var yearMonthDay: String {
        Date.formatter.dateFormat = "yyyy-MM-dd"
        return Date.formatter.stringFromDate(self)
    }
    
    public var year: String {
        Date.formatter.dateFormat = "yyyy"
        return Date.formatter.stringFromDate(self)
    }
    
    public var month: String {
        Date.formatter.dateFormat = "MM"
        return Date.formatter.stringFromDate(self)
    }
    
    public var day: String {
        Date.formatter.dateFormat = "dd"
        return Date.formatter.stringFromDate(self)
    }
    
    public var hour: String {
        Date.formatter.dateFormat = "HH"
        return Date.formatter.stringFromDate(self)
    }
    
    public var minute: String {
        Date.formatter.dateFormat = "mm"
        return Date.formatter.stringFromDate(self)
    }
    
    public var time: String {
        Date.formatter.dateFormat = "HH:mm"
        return Date.formatter.stringFromDate(self)
    }
    
    public var weekIndex: Int {
        return NSDate().weekOfYear()
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
    
    // @returns 0...6
    // `0`: Sunday and `6`: Saturday
    public func weekdayIndex() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Calendar, .Weekday, .WeekdayOrdinal], fromDate: self)
        return components.weekday - 1
    }
    
    public  func weekOfYear() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Calendar, .WeekOfYear], fromDate: self)
        return components.weekOfYear
    }
    
    public func dateByAddingDays(days: Int) -> NSDate {
        let timeInterval = timeIntervalSinceReferenceDate + NSTimeInterval(d_DAY * days)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public class func xh_dateWithDaysFromNow(days: Int) -> NSDate {
        return NSDate().dateByAddingDays(days)
    }
    
    public func dateBySubtractingDays(days: Int) -> NSDate {
        return dateByAddingDays(days * -1)
    }
    
    public class func xh_dateWithDaysBeforeNow(days: Int) -> NSDate {
        return NSDate().dateBySubtractingDays(days)
    }
    
    public class func as_dateFromString(aString: String, withFormat format: String = NSDate.timestampFormatString) -> NSDate? {
        let inputFormatter = NSDateFormatter()
        inputFormatter.dateFormat = format
        
        return inputFormatter.dateFromString(aString)
    }
    
    public class func daysOffsetBetweenStartDate(startDate: NSDate, endDate: NSDate) -> Int {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        let comps = gregorian?.components(.Day, fromDate: startDate, toDate: endDate, options: .WrapComponents)
        return (comps?.day ?? 0)
    }
}