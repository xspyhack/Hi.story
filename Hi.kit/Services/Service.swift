//
//  Service.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

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

public typealias JSONDictionary = [String: Any]

public protocol Serializable {
    init?(json: JSONDictionary)
}

public struct Service {
    
    static func god(of realm: Realm) -> User? {
        guard let userID = HiUserDefaults.userID.value else { return nil }
        
        let predicate = NSPredicate(format: "id = %@", userID)
        
        #if DEBUG
            let users = realm.objects(User.self).filter(predicate)
            if users.count > 1 {
                print("Warning: same user id: \(users.count), \(userID)")
            }
        #endif
        
        return realm.objects(User.self).filter(predicate).first
    }
    
    static var god: User? {
        guard let realm = try? Realm() else { return nil }
        
        return god(of: realm)
    }
}
