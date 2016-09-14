//
//  DispatchQueue.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 7/24/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public struct DispatchQueue {
    
    public enum DispatchQueueType {
        case main
        case `default`
        case high
        case background
        case low
    }
    
    public static func async(on queue: DispatchQueueType = .main, forWork block: @escaping ()->()) {
        
        switch queue {
        case .main:
            SafeDispatch.async { block() }
        case .default:
            SafeDispatch.async(onQueue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), forWork: { 
                block()
            })
        case .low:
            SafeDispatch.async(onQueue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low), forWork: {
                block()
            })
        case .high:
            SafeDispatch.async(onQueue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high), forWork: {
                block()
            })
        case .background:
            SafeDispatch.async(onQueue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background), forWork: {
                block()
            })
        }
    }
}

// MARK: - Safe Dispatch Queue
// ref: https://github.com/catchchat/Yep

open class SafeDispatch {
    
    fileprivate let mainQueueKey = UnsafeMutableRawPointer.allocate(capacity: 1)
    fileprivate let mainQueueValue = UnsafeMutableRawPointer.allocate(capacity: 1)
    
    fileprivate static let sharedSafeDispatch = SafeDispatch()
    
    fileprivate init() {
        DispatchQueue.main.setSpecific(key: /*Migrator FIXME: Use a variable of type DispatchSpecificKey*/ mainQueueKey, value: mainQueueValue)
    }
    
    open class func async(onQueue queue: Dispatch.DispatchQueue = DispatchQueue.main, forWork block: @escaping ()->()) {
        if queue === DispatchQueue.main {
            if DispatchQueue.getSpecific(sharedSafeDispatch.mainQueueKey) == sharedSafeDispatch.mainQueueValue {
                block()
            } else {
                DispatchQueue.main.async {
                    block()
                }
            }
        } else {
            queue.async {
                block()
            }
        }
    }
}
