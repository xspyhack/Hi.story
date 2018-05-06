//
//  Caches.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 17/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public struct Caches<Object>: Caching {
    
    var caches: [AnyCache<Object>]
    
    public var serializer: AnyCacheSerializer<Object>
    
    public func store(_ object: Object, forKey key: String) {
        coordinate({ cache, finished in
            cache.store(object, forKey: key)
        }, completion: {
            //
        })
    }
    
    public func retrieve(forKey key: String) -> Object? {
        return nil
    }
    
    public func remove(forKey key: String) {
        coordinate({ cache, finished in
            cache.remove(forKey: key)
        }, completion: {
            
        })
    }
    
    public func removeAll() {
        coordinate({ cache, finished in
            cache.removeAll()
        }, completion: {
            
        })
    }
    
    public func contains(forKey key: String) -> Bool {
        return false
    }
    
    private func coordinate(_ each: ((AnyCache<Object>, (() -> Void)?) -> Void), completion: (() -> Void)?) {
        // Count starts with the count of caches
        let count = Int32(caches.count)
        
        let finish: () -> Void = {
            // Safely decrement the count
            
            // If the count is 0, we're received all of the callbacks.
            if count == 0 {
                // Call the completion
                completion?()
            }
        }
        
        // Kick off the work for each cache
        caches.forEach { each($0, finish) }
    }
    
}
