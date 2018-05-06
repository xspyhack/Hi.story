//
//  Delay.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/23/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

public typealias Task = (_ cancel: Bool) -> Void

@discardableResult
public func delay(_ time: TimeInterval, task: @escaping () -> Void) -> Task? {
    
    func dispatchLater(_ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: block)
    }
    
    var closure: (() -> Void)? = task
    var result: Task?
    
    let delayedClosure: Task = { cancel in
        if let internalClosure = closure {
            if !cancel {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatchLater {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    
    return result
}

public func cancel(_ task: Task?) {
    task?(true)
}

// http://stackoverflow.com/questions/15161434/how-do-you-schedule-a-block-to-run-on-the-next-run-loop-iteration
// http://blog.ibireme.com/2015/05/18/runloop/
public func doInNextRunLoop(_ job: @escaping () -> Void) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0)) {
        job()
    }
}
