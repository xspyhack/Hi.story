//
//  Functor.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/**
 Map a function over an array.
 The currying version (f: (A) -> B) -> ([A]) -> [B]
 
 - parameter f: A function from `A` to `B`.
 - parameter x: An array of `A`.
 
 - returns: An array of `B`.
 */
public func <^> <A, B>(_ f: (A) -> B, _ x: [A]) -> [B] {
    return x.map(f)
}

/**
 Map a function over an optional value.
 The currying version (f: (A) -> B) -> (A?) -> B?
 
 - parameter f: A function from `A` to `B`.
 - parameter x: An optional of `A`.
 
 - returns: An optional of `B`.
 */
public func <^> <A, B>(_ f: (A) -> B, _ x: A?) -> B? {
    return x.map(f)
}
