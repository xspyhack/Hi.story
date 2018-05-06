//
//  Date+Hi.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 9/17/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

extension Date: HistoryCompatible {
}

public extension Hi where Base == Date {

    public var timestamp: String {
        _Date.formatter.dateFormat = Date.timestampFormatString
        return _Date.formatter.string(from: base)
    }
    
    public var dmyAtHourMinute: String {
        _Date.formatter.dateFormat = "dd MMM, yyyy 'at' HH:mm"
        return _Date.formatter.string(from: base)
    }
    
    public var monthDayYear: String {
        _Date.formatter.dateFormat = Date.mdyDateFormatString
        return _Date.formatter.string(from: base)
    }

    public var yearMonthDay: String {
        _Date.formatter.dateFormat = "yyyy/MM/dd"
        return _Date.formatter.string(from: base)
    }
    
    public var monthDay: String {
        _Date.formatter.dateFormat = "MM/dd"
        return _Date.formatter.string(from: base)
    }

    public var year: String {
        _Date.formatter.dateFormat = "yyyy"
        return _Date.formatter.string(from: base)
    }

    public var month: String {
        _Date.formatter.dateFormat = "MM"
        return _Date.formatter.string(from: base)
    }

    public var day: String {
        _Date.formatter.dateFormat = "dd"
        return _Date.formatter.string(from: base)
    }

    public var hour: String {
        _Date.formatter.dateFormat = "HH"
        return _Date.formatter.string(from: base)
    }

    public var minute: String {
        _Date.formatter.dateFormat = "mm"
        return _Date.formatter.string(from: base)
    }

    public var time: String {
        _Date.formatter.dateFormat = "HH:mm"
        return _Date.formatter.string(from: base)
    }

    public func days(with comparingDate: Date) -> Int {
        return Hi.daysOffset(between: base, and: comparingDate)
    }
    
    public func absoluteDays(with comparingDate: Date) -> Int {
        return Hi.absoluteDaysOffset(between: base, and: comparingDate)
    }
    
    public static func daysOffset(between startDate: Date, and endDate: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let comps = gregorian.dateComponents([.day], from: startDate, to: endDate)
        return (comps.day ?? 0)
    }
    
    public static func absoluteDaysOffset(between startDate: Date, and endDate: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let fromDate = gregorian.date(bySettingHour: 12, minute: 0, second: 0, of: startDate) ?? startDate
        let toDate = gregorian.date(bySettingHour: 12, minute: 0, second: 0, of: endDate) ?? endDate
        
        let comps = gregorian.dateComponents([.day], from: fromDate, to: toDate)
        return (comps.day ?? 0)
    }

    
    public static func date(with aString: String, format: String = Date.timestampFormatString) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = format
        
        return inputFormatter.date(from: aString)
    }
    
    /// `0`: Sunday and `6`: Saturday
    /// -returns 0...6
    public var weekdayIndex: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.calendar, .weekday, .weekdayOrdinal], from: base)
        return (components.weekday ?? 0) - 1
    }
}

private struct _Date {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // No localized string
        return formatter
    }()
}

public extension Date {
    
    private struct _Date {
        static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US") // No localized string
            return formatter
        }()
    }
    
    static let dateFormatString = "yyyy-MM-dd"
    static let mdyDateFormatString = "MMM dd, yyy"
    static let timeFormatString = "HH:mm:ss"
    static let timestampFormatString = "yyyy-MM-dd'T'HH:mm:ssZ"
}

extension Int: HistoryCompatible {
}

public extension Hi where Base == Int {
    
    public var day: TimeInterval {
        let DAY_IN_SECONDS = 60 * 60 * 24
        return Double(DAY_IN_SECONDS) * Double(base)
    }
    
    var months: _TimeInterval {
        return _TimeInterval(interval: base, unit: .months);
    }
    
    var days: _TimeInterval {
        return _TimeInterval(interval: base, unit: .days)
    }
    
    var years: _TimeInterval {
        return _TimeInterval(interval: base, unit: .years)
    }
}

public struct _TimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    public var ago: Date {
        let calendar = Calendar.current
        let today = Date()
        let components = unit.dateComponents(-self.interval)
        return calendar.date(byAdding: components, to: today)!
    }
    
    public var after: Date {
        let calendar = Calendar.current
        let today = Date()
        let components = unit.dateComponents(self.interval)
        return calendar.date(byAdding: components, to: today)!
    }
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

public enum TimeIntervalUnit {
    
    case seconds, minutes, hours, days, months, years
    
    func dateComponents(_ interval: Int) -> DateComponents {
        var components: DateComponents = DateComponents()
        
        switch (self) {
        case .seconds:
            components.second = interval
        case .minutes:
            components.minute = interval
        case .days:
            components.day = interval
        case .months:
            components.month = interval
        case .years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

