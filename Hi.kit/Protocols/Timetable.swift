//
//  Timetable.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 12/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public protocol Timetable {
    
    var createdAt: TimeInterval { get }
    
    var monthDay: String { get }
    var year: String { get }
}

public extension Timetable {

    public var monthDay: String {
        return Date(timeIntervalSince1970: createdAt).hi.monthDay
    }
    
    public var year: String {
        return Date(timeIntervalSince1970: createdAt).hi.year
    }
}

