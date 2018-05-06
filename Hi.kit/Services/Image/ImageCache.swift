//
//  CacheService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 30/09/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hicache

public class CacheService {
    
    public static let shared = CacheService()
    
    private let cache: Cache<UIImage>
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let cacheDirectory = (path as NSString).appendingPathComponent("image")
        self.cache = Cache<UIImage>(directory: cacheDirectory, serializer: ImageCacheSerializer())
    }
    
    public func store(_ image: UIImage, forKey key: String, completionHandler: (() -> Void)? = nil) {
        if let completionHandler = completionHandler {
            cache.store(image, forKey: key.hi.md5 ?? key, completionHandler: completionHandler)
        } else {
            cache.store(image, forKey: key.hi.md5 ?? key)
        }
    }
    
    public func remove(forKey key: String) {
        cache.remove(forKey: key.hi.md5 ?? key)
    }
    
    public func retrieve(forKey key: String) -> UIImage? {
        return cache.retrieve(forKey: key.hi.md5 ?? key)
    }
    
    public func retrieve(forKey key: String, completionHandler: @escaping ((UIImage?) -> Void)) {
        return cache.retrieve(forKey: key.hi.md5 ?? key, completionHandler: completionHandler)
    }
    
    public func contains(forKey key: String) -> Bool {
        return cache.contains(forKey: key.hi.md5 ?? key)
    }
    
    public func filePath(forKey key: String) -> String {
        return cache.fileURL(forKey: key.hi.md5 ?? key).absoluteString
    }
    
    public static let sharedCache = CacheService.shared.cache
}
