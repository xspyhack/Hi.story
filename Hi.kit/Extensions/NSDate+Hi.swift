//
//  NSDate+Hi.swift
//  Hi.kit
//

//  Created by bl4ckra1sond3tre on 10/9/15.
//  Copyright © 2015 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

fileprivate let d_DAY: Int = 86400

public extension Hi where Base: NSDate {
    
    public var timestamp: String {
        _Date.formatter.dateFormat = NSDate.timestampFormatString
        return _Date.formatter.string(from: base as Date)
    }
    
    public var monthDayYear: String {
        _Date.formatter.dateFormat = NSDate.mdyDateFormatString
        return _Date.formatter.string(from: base as Date)
    }
    
    public var yearMonthDay: String {
        _Date.formatter.dateFormat = "yyyy/MM/dd"
        return _Date.formatter.string(from: base as Date)
    }
    
    public var year: String {
        _Date.formatter.dateFormat = "yyyy"
        return _Date.formatter.string(from: base as Date)
    }
    
    public var month: String {
        _Date.formatter.dateFormat = "MM"
        return _Date.formatter.string(from: base as Date)
    }
    
    public var day: String {
        _Date.formatter.dateFormat = "dd"
        return _Date.formatter.string(from: base as Date)
    }
    
    public var hour: String {
        _Date.formatter.dateFormat = "HH"
        return _Date.formatter.string(from: base as Date)
    }
    
    public var minute: String {
        _Date.formatter.dateFormat = "mm"
        return _Date.formatter.string(from: base as Date)
    }
    
    public var time: String {
        _Date.formatter.dateFormat = "HH:mm"
        return _Date.formatter.string(from: base as Date)
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
        
        return NSDate.hi.daysOffset(between: base as Date, and: comparingDate as Date)
    }
    
    public func absoluteDays(widthDate comparingDate: NSDate) -> Int {
        return NSDate.hi.absoluteDaysOffset(between: base as Date, and: comparingDate as Date)
    }
    
    // @returns 0...6
    // `0`: Sunday and `6`: Saturday
    public func weekdayIndex() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.calendar, .weekday, .weekdayOrdinal], from: base as Date)
        return components.weekday! - 1
    }
    
    public func weekOfYear() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.calendar, .weekOfYear], from: base as Date)
        return components.weekOfYear!
    }
    
    public func dateByAddingDays(_ days: Int) -> Date {
        let timeInterval = Date.timeIntervalSinceReferenceDate + TimeInterval(d_DAY * days)
        let newDate = Foundation.Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateWithDaysFromNow(_ days: Int) -> Date {
        return NSDate().hi.dateByAddingDays(days)
    }
    
    public func dateBySubtractingDays(_ days: Int) -> Date {
        return dateByAddingDays(days * -1)
    }
    
    public func dateWithDaysBeforeNow(_ days: Int) -> Date {
        return NSDate().hi.dateBySubtractingDays(days)
    }
}

public extension X where Base: NSDate {
    
    public static func daysOffset(between startDate: Date, and endDate: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let comps = (gregorian as NSCalendar?)?.components(.day, from: startDate, to: endDate, options: .wrapComponents)
        return (comps?.day ?? 0)
    }
    
    public static func absoluteDaysOffset(between startDate: Date, and endDate: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let fromDate = gregorian.date(bySettingHour: 12, minute: 0, second: 0, of: startDate) ?? startDate
        let toDate = gregorian.date(bySettingHour: 12, minute: 0, second: 0, of: endDate) ?? endDate
        
        let comps = (gregorian as NSCalendar?)?.components(.day, from: fromDate, to: toDate, options: .wrapComponents)
        return (comps?.day ?? 0)
    }
    
    public static func dateFromString(_ aString: String, withFormat format: String = NSDate.timestampFormatString) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = format
        
        return inputFormatter.date(from: aString)
    }
}

fileprivate struct _Date {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // No localized string
        return formatter
    }()
}

public extension NSDate {
    
    fileprivate struct _Date {
        static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US") // No localized string
            return formatter
        }()
    }
    
    fileprivate static let dateFormatString = "yyyy-MM-dd"
    fileprivate static let mdyDateFormatString = "MMM dd, yyy"
    fileprivate static let timeFormatString = "HH:mm:ss"
    fileprivate static let timestampFormatString = "yyyy-MM-dd'T'HH:mm:ssZ"

}
