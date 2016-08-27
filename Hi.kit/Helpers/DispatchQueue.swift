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
        case Main
        case Default
        case High
        case Background
        case Low
    }
    
    public static func async(on queue: DispatchQueueType = .Main, forWork block: dispatch_block_t) {
        
        switch queue {
        case .Main:
            SafeDispatch.async { block() }
        case .Default:
            SafeDispatch.async(onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), forWork: { 
                block()
            })
        case .Low:
            SafeDispatch.async(onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), forWork: {
                block()
            })
        case .High:
            SafeDispatch.async(onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), forWork: {
                block()
            })
        case .Background:
            SafeDispatch.async(onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), forWork: {
                block()
            })
        }
    }
}

// MARK: - Safe Dispatch Queue
// ref: https://github.com/catchchat/Yep

public class SafeDispatch {
    
    private let mainQueueKey = UnsafeMutablePointer<Void>.alloc(1)
    private let mainQueueValue = UnsafeMutablePointer<Void>.alloc(1)
    
    private static let sharedSafeDispatch = SafeDispatch()
    
    private init() {
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, mainQueueValue, nil)
    }
    
    public class func async(onQueue queue: dispatch_queue_t = dispatch_get_main_queue(), forWork block: dispatch_block_t) {
        if queue === dispatch_get_main_queue() {
            if dispatch_get_specific(sharedSafeDispatch.mainQueueKey) == sharedSafeDispatch.mainQueueValue {
                block()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    block()
                }
            }
        } else {
            dispatch_async(queue) {
                block()
            }
        }
    }
}
