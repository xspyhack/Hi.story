//
//  NSDate+Hi.swift
//  Hi.kit
//

//  Created by bl4ckra1sond3tre on 10/9/15.
//  Copyright © 2015 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

private let d_DAY: Int = 86400

public extension Hi where Base: Foundation.Date {
    
    public var timestamp: String {
        Date.formatter.dateFormat = Foundation.Date.timestampFormatString
        return Date.formatter.string(from: base)
    }
    
    public var monthDayYear: String {
        Date.formatter.dateFormat = Foundation.Date.mdyDateFormatString
        return Date.formatter.string(from: base)
    }
    
    public var yearMonthDay: String {
        Date.formatter.dateFormat = "yyyy/MM/dd"
        return Date.formatter.string(from: base)
    }
    
    public var year: String {
        Date.formatter.dateFormat = "yyyy"
        return Date.formatter.string(from: base)
    }
    
    public var month: String {
        Date.formatter.dateFormat = "MM"
        return Date.formatter.string(from: base)
    }
    
    public var day: String {
        Date.formatter.dateFormat = "dd"
        return Date.formatter.string(from: base)
    }
    
    public var hour: String {
        Date.formatter.dateFormat = "HH"
        return Date.formatter.string(from: base)
    }
    
    public var minute: String {
        Date.formatter.dateFormat = "mm"
        return Date.formatter.string(from: base)
    }
    
    public var time: String {
        Date.formatter.dateFormat = "HH:mm"
        return Date.formatter.string(from: base)
    }
    
    public var weekIndex: Int {
        return Foundation.Date().hi.weekOfYear()
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
    
    public func days(withDate comparingDate: Foundation.Date) -> Int {
        
        return Foundation.Date.hi.daysOffset(between: base, with: comparingDate)
    }
    
    // @returns 0...6
    // `0`: Sunday and `6`: Saturday
    public func weekdayIndex() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.calendar, .weekday, .weekdayOrdinal], from: base)
        return components.weekday - 1
    }
    
    public func weekOfYear() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.calendar, .weekOfYear], from: base)
        return components.weekOfYear
    }
    
    public func dateByAddingDays(_ days: Int) -> Foundation.Date {
        let timeInterval = base.timeIntervalSinceReferenceDate + TimeInterval(d_DAY * days)
        let newDate = Foundation.Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateWithDaysFromNow(_ days: Int) -> Foundation.Date {
        return Foundation.Date().hi.dateByAddingDays(days)
    }
    
    public func dateBySubtractingDays(_ days: Int) -> Foundation.Date {
        return dateByAddingDays(days * -1)
    }
    
    public func dateWithDaysBeforeNow(_ days: Int) -> Foundation.Date {
        return Foundation.Date().hi.dateBySubtractingDays(days)
    }
}

public extension X where Base: Foundation.Date {
    
    public static func daysOffset(between startDate: Foundation.Date, with endDate: Foundation.Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let comps = (gregorian as NSCalendar?)?.components(.day, from: startDate, to: endDate, options: .wrapComponents)
        return (comps?.day ?? 0)
    }
    
    public static func dateFromString(_ aString: String, withFormat format: String = Foundation.Date.timestampFormatString) -> Foundation.Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = format
        
        return inputFormatter.date(from: aString)
    }
}

private struct Date {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // No localized string
        return formatter
    }()
}

public extension Foundation.Date {
    
    fileprivate struct Date {
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
