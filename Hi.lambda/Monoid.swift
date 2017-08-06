//
//  Monoid.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/**
 A monoid is a semigroup with an identity element.
 
 see also http://blessingsoft.com/2017/06/12/group-theory-and-category-theory/
 */
public protocol Monoid : Semigroup {
    static var identity: Self { get }
}

extension Int : Monoid {
    public static var identity = 0
}

extension Bool : Monoid {
    public static var identity = true
}

extension String : Monoid {
    public static var identity = ""
}

extension Array : Monoid {
    public static var identity: Array {
        return []
    }
}

extension Set : Monoid {
    public static var identity: Set {
        return Set()
    }
}

/// fold the 
public func concat<M: Monoid>(_ xs: [M]) -> M {
    return xs.reduce(M.identity, <>)
}
