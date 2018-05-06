//
//  Route.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/03/2018.
//  Copyright © 2018 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Argo
import Runes

public typealias Params = JSON

public func curry<A, B>(_ f: @escaping (A) -> B) -> (A) -> B {
    return { a in f(a) }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

public struct Route {
    let pattern: String
    let handler: ((Params) -> Void)?
    
    public init(_ pattern: String, handler: ((Params) -> Void)? = nil) {
        self.pattern = pattern
        self.handler = handler
    }
}

extension Route: Hashable {
    public static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.pattern == rhs.pattern
    }
    
    public var hashValue: Int {
        return pattern.hashValue
    }
}

extension Params {
    
    // 指的是 .object
    var isValided: Bool {
        if case .object = self {
            return true
        } else {
            return false
        }
    }
    
    static func + (lhs: Params, rhs: Params) throws -> Params {
        guard case .object(let lo) = lhs, case .object(let ro) = rhs else {
            throw DecodeError.custom("Canot combine invalid param")
        }
        
        var object = lo
        
        for (key, value) in ro {
            object[key] = value
        }
        
        return .object(object)
    }
    
    func value(forKey key: String) -> String? {
        return (curry(String.init) <^> self <| "id").value
    }
}

precedencegroup LeftApplyPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

infix operator |>> : LeftApplyPrecedence

public func |>> (params: Params, key: String) -> String? {
    return params.value(forKey: key)
}
