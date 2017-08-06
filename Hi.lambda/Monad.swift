//
//  Monad.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 04/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/**
 x = id(x)
 */
public func unit<A>(_ x: A) -> [A] {
    return [x]
}

/**
 `F⊗F -> F` or `M(M(X)) -> M(X)`
 */
public func join<A>(_ xs: [[A]]) -> [A] {
    return Array(xs.joined())
}

/**
 Bind an array of `A` to a transform function which is from `A` to array `B`, also call `bind`.
 If type `A` is a typeof `Sequence`, the result will be flatten.
 bind = map + join.
 
 - parameter x: An array of `A`.
 - parameter f: A function from `A` to array `B`.
 
 - returns: An array of `B`.
 */
public func >>- <A, B>(_ x: [A], f: (A) -> [B]) -> [B] {
    return x.flatMap(f)
}

/**
 Bind an optional value of `A` to a transform function that from `A` to optional `B`, also call `bind`.
 
 - parameter x: An optional value of `A`.
 - parameter f: A function from `A` to optional `B`.
 
 - returns: An optional value of `B`.
 */
public func >>- <A, B>(_ x: A?, f: (A) -> B?) -> B? {
    return x.flatMap(f)
}
