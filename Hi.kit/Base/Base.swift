//
//  Base.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/// We need to extension Any struct/class, not only AnyObject, such as String
/// You can use <Base: AnyObject>
public struct Hi<Base: AnyObject> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
    
    public static var base: Base.Type {
        return Base.self
    }
}

public extension NSObjectProtocol {
    public var hi: Hi<Self> {
        return Hi(self)
    }
    
    public static var hi: Hi<Self>.Type {
        return Hi.self
    }
}

public struct K<Base: BaseType> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public typealias BaseType = BaseProtocol

public protocol BaseProtocol {
    associatedtype Base
    
    var hi: Base { get }
    static var hi: Base.Type { get }
}

public extension BaseProtocol {
    
    public var hi: K<Self> {
        return K(self)
    }
    
    public static var hi: K<Self>.Type {
        return K.self
    }
}
