//
//  Caches.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 17/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public struct Caches<Object>: Caching {
    
    var caches: [AnyAsyncCache<Object>]
    
    public var serializer: AnyCacheSerializer<Object>
    
    public func store(_ object: Object, forKey key: String) {
        coordinate({ cache, finished in
            cache.store(object, forKey: key)
        }, completion: {
            //
        })
    }
    
    public func retrieve(forKey key: String) -> Object? {
        for cache in caches {
            if let object = cache.retrieve(forKey: key) {
                return object
            }
        }
        return nil
    }

    public func retrieve(forKey key: String, completion: @escaping (Object?, String) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)

        for cache in caches {
            cache.retrieve(forKey: key) { object, key in
                if let object = object {
                    completion(object, key)
                    semaphore.signal()
                    return
                }
                semaphore.signal()
            }

            let _ = semaphore.wait(timeout: .distantFuture)
        }

        completion(nil, key)
    }
    
    public func remove(forKey key: String) {
        coordinate({ cache, finished in
            cache.remove(forKey: key, completionHandler: finished)
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
    
    private func coordinate(_ each: ((AnyAsyncCache<Object>, (@escaping (String) -> Void)) -> Void), completion: (() -> Void)?) {

        let group = DispatchGroup()

        // Kick off the work for each cache
        caches.forEach {
            group.enter()
            each($0) { key in
                group.leave()
            }
        }

        if let completion = completion {
            group.notify(queue: DispatchQueue.main, execute: completion)
        }
    }
    
}
