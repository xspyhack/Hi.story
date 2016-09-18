//
//  Date+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/17/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

//extension Date: BaseType {
//    
//    public var timestamp: String {
//        _Date.formatter.dateFormat = Date.timestampFormatString
//        return _Date.formatter.string(from: self)
//    }
//    
//    public var monthDayYear: String {
//        _Date.formatter.dateFormat = Date.mdyDateFormatString
//        return _Date.formatter.string(from: self)
//    }
//
//    public var yearMonthDay: String {
//        _Date.formatter.dateFormat = "yyyy/MM/dd"
//        return _Date.formatter.string(from: self)
//    }
//
//    public var year: String {
//        _Date.formatter.dateFormat = "yyyy"
//        return _Date.formatter.string(from: self)
//    }
//
//    public var month: String {
//        _Date.formatter.dateFormat = "MM"
//        return _Date.formatter.string(from: self)
//    }
//
//    public var day: String {
//        _Date.formatter.dateFormat = "dd"
//        return _Date.formatter.string(from: self)
//    }
//
//    public var hour: String {
//        _Date.formatter.dateFormat = "HH"
//        return _Date.formatter.string(from: self)
//    }
//
//    public var minute: String {
//        _Date.formatter.dateFormat = "mm"
//        return _Date.formatter.string(from: self)
//    }
//
//    public var time: String {
//        _Date.formatter.dateFormat = "HH:mm"
//        return _Date.formatter.string(from: self)
//    }
//
//}
//
//fileprivate struct _Date {
//    static let formatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US") // No localized string
//        return formatter
//    }()
//}
//
//public extension Date {
//    
//    fileprivate struct _Date {
//        static let formatter: DateFormatter = {
//            let formatter = DateFormatter()
//            formatter.locale = Locale(identifier: "en_US") // No localized string
//            return formatter
//        }()
//    }
//    
//    fileprivate static let dateFormatString = "yyyy-MM-dd"
//    fileprivate static let mdyDateFormatString = "MMM dd, yyy"
//    fileprivate static let timeFormatString = "HH:mm:ss"
//    fileprivate static let timestampFormatString = "yyyy-MM-dd'T'HH:mm:ssZ"
//    
//}
