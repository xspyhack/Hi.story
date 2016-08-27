//
//  Base.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public struct Hi<Base: AnyObject> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public extension NSObjectProtocol {
    public var hi: Hi<Self> {
        return Hi(self)
    }
}
