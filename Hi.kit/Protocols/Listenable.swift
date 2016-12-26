//
//  Listenable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 12/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public struct Listener<T>: Hashable {
    
    let name: String
    
    public typealias Action = (T) -> Void
    let action: Action
    
    public var hashValue: Int {
        return name.hashValue
    }
}

public func ==<T>(lhs: Listener<T>, rhs: Listener<T>) -> Bool {
    return lhs.name == rhs.name
}

public class Listenable<U> {
    
    public typealias SetterAction = (U) -> Void
    
    public var value: U {
        didSet {
            setterAction(value)
            
            for listener in listenerSet {
                listener.action(value)
            }
        }
    }
    
    var setterAction: (U) -> Void
    
    /// Note: new listener won't not replace the old listener, it will be skip.
    var listenerSet: Set<Listener<U>> = []
    
    public func bindListener(with name: String, action: @escaping Listener<U>.Action) {
        let listener = Listener(name: name, action: action)
        
        listenerSet.insert(listener)
    }
    
    public func bindAndFireListener(with name: String, action: @escaping Listener<U>.Action) {
        bindListener(with: name, action: action)
        
        action(value)
    }
    
    public func removeListener(with name: String) {
        for listener in listenerSet {
            if listener.name == name {
                listenerSet.remove(listener)
                break
            }
        }
    }
    
    public func removeAllListeners() {
        listenerSet.removeAll(keepingCapacity: false)
    }
    
    public init(_ v: U, setterAction action: @escaping SetterAction) {
        value = v
        setterAction = action
    }
}
