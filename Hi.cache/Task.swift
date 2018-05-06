//
//  Task.swift
//  Hicache
//
//  Created by bl4ckra1sond3tre on 29/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public struct Task {
    
    public let key: String
    
    private let work: DispatchWorkItem
    
    public init(key: String, block: @escaping @convention(block) () -> Void) {
        self.key = key
        self.work = DispatchWorkItem(block: block)
    }
    
    public init(key: String, work: DispatchWorkItem) {
        self.key = key
        self.work = work
    }
    
    public func cancel() {
        work.cancel()
    }
    
    public func wait() {
        work.wait()
    }
    
    public func wait(timeout: DispatchTime) -> DispatchTimeoutResult {
        return work.wait(timeout: timeout)
    }
    
    public func wait(wallTimeout: DispatchWallTime) -> DispatchTimeoutResult {
        return work.wait(wallTimeout: wallTimeout)
    }
}
