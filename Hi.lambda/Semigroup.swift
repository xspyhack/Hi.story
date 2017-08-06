//
//  Semigroup.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/**
 A Semigroup must satisfies `Closure`, `Associativity` and has a `Binary operation`
 
 see also http://blessingsoft.com/2017/06/12/group-theory-and-category-theory/
 */
public protocol Semigroup {
    // For all a, b, c : Semigroup, (a <> b) <> c = a <> (b <> c)
    static func <> (lhs: Self, rhs: Self) -> Self
}

extension Int : Semigroup {
    public static func <> (lhs: Int, rhs: Int) -> Int {
        return lhs + rhs
    }
}

extension Bool : Semigroup {
    public static func <> (lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }
}

extension String : Semigroup {
    public static func <> (lhs: String, rhs: String) -> String {
        return lhs + rhs
    }
}

extension Array : Semigroup {
    public static func <> (lhs: Array, rhs: Array) -> Array {
        return lhs + rhs
    }
}

extension Set : Semigroup {
    public static func <> (lhs: Set, rhs: Set) -> Set {
        return lhs.union(rhs)
    }
}

public func <> <S: Semigroup> (lhs: S, rhs: S) -> S {
    return lhs <> rhs
}
