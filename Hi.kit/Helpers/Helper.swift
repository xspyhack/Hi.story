//
//  Helper.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 26/04/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

// Fuck Any

func noOp<T>(x: T) -> T {
    return x
}

/// Documenting force-unwraps

infix operator !!

public func !!<T>(lhs: T?, rhs: String) -> T {
    guard let unwrapped = lhs else { fatalError(rhs) }
    return unwrapped
}

infix operator <>: AdditionPrecedence


/// Semigroup

public protocol Semigroup {
    static func <>(lhs: Self, rhs: Self) -> Self
}

extension Int: Semigroup {
    
    public static func <>(lhs: Int, rhs: Int) -> Int {
        return lhs + rhs
    }
}

extension Bool: Semigroup {
    
    public static func <>(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }
}

extension Array: Semigroup {
    
    public static func <>(lhs: Array, rhs: Array) -> Array {
        return lhs + rhs
    }
}

public func concat<S: Semigroup>(_ xs: [S], _ initial: S) -> S {
    return xs.reduce(initial, <>)
}

public protocol Monoid: Semigroup {
    static var e: Self { get }
}

extension Int: Monoid {
    public static var e = 0
}

extension Bool: Monoid {
    public static var e = true
}

extension Array: Monoid {
    public static var e: Array {
        return []
    }
}

public func concat<M: Monoid>(_ xs: [M]) -> M {
    return xs.reduce(M.e, <>)
}
