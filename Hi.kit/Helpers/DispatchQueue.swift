//
//  DispatchQueue.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 7/24/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

// MARK: - Safe Dispatch Queue
// ref: https://github.com/catchchat/Yep

public class SafeDispatch {

    private let mainQueueKey = DispatchSpecificKey<String>()
    private let mainQueueValue = "main"
    
    private static let shared = SafeDispatch()
    
    private init() {
        
        DispatchQueue.main.setSpecific(key: mainQueueKey, value: mainQueueValue)
    }
    
    public class func async(onQueue queue: DispatchQueue = .main, forWork block: @escaping ()->()) {
        if queue === DispatchQueue.main {
            if DispatchQueue.getSpecific(key: shared.mainQueueKey) == shared.mainQueueValue {
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
