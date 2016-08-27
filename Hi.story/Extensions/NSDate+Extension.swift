//
//  NSDate+Extension.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 10/9/15.
//  Copyright © 2015 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

private let d_DAY: Int = 86400

extension NSDate {
    
    private struct Date {
        static let formatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US") // No localized string
            return formatter
        }()
    }
    
    private static let xh_dateFormatString = "yyyy-MM-dd"
    private static let xh_mdyDateFormatString = "MMM dd, yyy"
    private static let xh_timeFormatString = "HH:mm:ss"
    private static let xh_timestampFormatString = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    class func xh_dateFromString(aString: String, withFormat format: String = NSDate.xh_timestampFormatString) -> NSDate? {
        let inputFormatter = NSDateFormatter()
        inputFormatter.dateFormat = format
        inputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        
        return inputFormatter.dateFromString(aString)
    }
    
    var xh_timestamp: String {
        Date.formatter.dateFormat = NSDate.xh_timestampFormatString
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_monthDayYear: String {
        Date.formatter.dateFormat = NSDate.xh_mdyDateFormatString
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_yearMonthDay: String {
        Date.formatter.dateFormat = "yyyy-MM-dd"
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_year: String {
        Date.formatter.dateFormat = "yyyy"
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_month: String {
        Date.formatter.dateFormat = "MM"
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_day: String {
        Date.formatter.dateFormat = "dd"
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_hour: String {
        Date.formatter.dateFormat = "HH"
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_minute: String {
        Date.formatter.dateFormat = "mm"
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_time: String {
        Date.formatter.dateFormat = "HH:mm"
        return Date.formatter.stringFromDate(self)
    }
    
    var xh_weekIndex: Int {
        return NSDate().xh_weekOfYear()
    }
    
    var xh_weekday: String {
        switch xh_weekdayIndex() {
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
            return "unknow"
        }
    }
    
    // @returns 0...6
    // `0`: Sunday and `6`: Saturday
    func xh_weekdayIndex() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Calendar, .Weekday, .WeekdayOrdinal], fromDate: self)
        return components.weekday - 1
    }
    
    private func xh_weekOfYear() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Calendar, .WeekOfYear], fromDate: self)
        return components.weekOfYear
    }
    
    func xh_dateByAddingDays(days: Int) -> NSDate {
        let timeInterval = timeIntervalSinceReferenceDate + NSTimeInterval(d_DAY * days)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    func days(withDate comparingDate: NSDate) -> Int {
        
        return NSDate.daysOffset(between: self, endDate: comparingDate)
    }
    
    class func xh_dateWithDaysFromNow(days: Int) -> NSDate {
        return NSDate().xh_dateByAddingDays(days)
    }
    
    func xh_dateBySubtractingDays(days: Int) -> NSDate {
        return xh_dateByAddingDays(days * -1)
    }
    
    class func xh_dateWithDaysBeforeNow(days: Int) -> NSDate {
        return NSDate().xh_dateBySubtractingDays(days)
    }

    class func daysOffset(between startDate: NSDate, endDate: NSDate) -> Int {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        let comps = gregorian?.components(.Day, fromDate: startDate, toDate: endDate, options: .WrapComponents)
        return (comps?.day ?? 0)
    }
}