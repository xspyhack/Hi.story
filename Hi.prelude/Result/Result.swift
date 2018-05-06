//
//  Result.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/03/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
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
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public extension Result {
    
    public func map<U>(_ f: (Value) -> U) -> Result<U> {
        switch self {
        case .success(let value): return .success(f(value))
        case .failure(let error): return .failure(error)
        }
    }
    
    public func flatMap<U>(_ f: (Value) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let value): return f(value)
        case .failure(let error): return .failure(error)
        }
    }
}

public extension Result {
    func dematerialize() throws -> Value {
        switch self {
        case let .success(value): return value
        case let .failure(error): throw error
        }
    }
}

public func materialize<T>(_ f: () throws -> T) -> Result<T> {
    do {
        return .success(try f())
    } catch {
        return .failure(error)
    }
}

