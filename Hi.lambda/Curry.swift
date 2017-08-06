//
//  Curry.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 04/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public func curry<A, B>(_ f: @escaping (A) -> B) -> (A) -> B {
    return { a in f(a) }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}
