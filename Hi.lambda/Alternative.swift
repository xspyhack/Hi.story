//
//  Alternative.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 04/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/**
 Return an empty context of array of `A`.
 */
public func empty<A>() -> [A] {
    return []
}

/**
 Concatenating two arrays.
 
 - parameter a: An array of `A`
 - parameter b: An array of `A`
 
 - returns: The result of concatenating `a` and `b`
 */
public func <|> <A> (_ a: [A], _ b: [A]) -> [A] {
    return a + b
}

/**
 Return an empty context of optional of `A`.
 */
public func empty<A>() -> A? {
    return .none
}

/**
 Choice a successful value or the default value.
 If parameter `a` is `.some`, return `a`.
 Or it will return the default value `b`.
 
 - parameter a: An optional value of `A`.
 - parameter b: A value to use as default, it is also optional value of `A`.
 
 - returns: An optional value of `A`
 */
public func <|> <A> (_ a: A?, _ b: A?) -> A? {
    return a ?? b
}
