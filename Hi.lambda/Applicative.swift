//
//  Applicative.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 04/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/**
 Lifting a value to an array.
 
 - parameter x: A value of type `A`.
 
 - returns: An array of `A`.
 */
public func pure<A>(_ x: A) -> [A] {
    return [x]
}

/**
 Apply an array of functions to an array value.
 
 - parameter fs: An array of function from `A` to `B`.
 - parameter xs: An array of `A`.
 
 - returns: An array of `B`.
 */
public func <*> <A, B> (_ fs: [(A) -> B], _ xs: [A]) -> [B] {
    return fs.flatMap { xs.map($0) }
}

/**
 Lifting a value to an optional.
 
 - parameter x: A value of type `A`.
 
 - returns: An optional value of `A`.
 */
public func pure<A>(_ x: A) -> A? {
    return .some(x)
}

/**
 Apply an optional function to an optional value.
 
 - parameter fs: An optional of function from `A` to `B`.
 - parameter xs: An optional value of `A`.
 
 - returns: An optional value of `B`.
 */
public func <*> <A, B>(_ f: ((A) -> B)?, x: A?) -> B? {
    return f.flatMap { x.map($0) }
}
