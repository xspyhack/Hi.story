//
//  Service.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case Success(Value)
    case Failure(String?)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: String? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
}

public extension Result {
    
    public func map<U>(f: Value -> U) -> Result<U> {
        switch self {
        case .Success(let value): return .Success(f(value))
        case .Failure(let error): return .Failure(error)
        }
    }
}

public typealias JSONDictionary = [String: AnyObject]

public protocol Serializable {
    init?(json: JSONDictionary)
}