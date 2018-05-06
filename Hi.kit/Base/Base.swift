
//
//  Base.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 8/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public final class Hi<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol HistoryCompatible {
    associatedtype BaseType
    
    var hi: Hi<BaseType> { get }
    static var hi: Hi<BaseType>.Type { get }
}

public extension HistoryCompatible {
    
    public var hi: Hi<Self> {
        return Hi(self)
    }
    
    public static var hi: Hi<Self>.Type {
        return Hi<Self>.self
    }
}

extension NSObject: HistoryCompatible {}
