//
//  Date+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/17/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public struct DateProxy {
    public let base: Date
    public init(_ base: Date) {
        self.base = base
    }
}

extension Date: BaseType {
    public typealias Base = DateProxy
    
    public var hi: DateProxy {
        return DateProxy(self)
    }
    
    public static var hi: DateProxy.Type {
        return DateProxy.self
    }
}

extension DateProxy {
    
    public var timestamp: String {
        _Date.formatter.dateFormat = Date.timestampFormatString
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

    public func days(withDate comparingDate: Date) -> Int {
        
        return Date.hi.daysOffset(between: base, and: comparingDate)
    }
    
    public static func daysOffset(between startDate: Date, and endDate: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let comps = (gregorian as NSCalendar?)?.components(.day, from: startDate, to: endDate, options: .wrapComponents)
        return (comps?.day ?? 0)
    }
    
    public static func dateFromString(_ aString: String, withFormat format: String = Date.timestampFormatString) -> Date? {
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

public extension Date {
    
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
