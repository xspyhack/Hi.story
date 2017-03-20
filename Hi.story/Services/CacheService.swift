//
//  CacheService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 30/09/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCache {
    static let shared = PhotoCache()
    
    private let cache = ImageCache(name: "photos")
    
    private init() {
        cache.pathExtension = "jpg"
        cache.maxCachePeriodInSecond = 60 * 5
    }
    
    func store(_ image: UIImage, forKey key: String, completionHandler: (() -> Void)? = nil) {
        cache.store(image, forKey: key, toDisk: true, completionHandler: completionHandler)
    }
    
    func removeIfExisting(forKey key: String) {
        cache.removeImage(forKey: key, fromDisk: true, completionHandler: nil)
    }
    
    func retrieveImageInDiskCache(forKey key: String, scale: CGFloat = 1.0) -> UIImage? {
        return cache.retrieveImageInDiskCache(forKey: key, options: [.scaleFactor(scale)])
    }
    
    func filePath(forKey key: String) -> String {
        return cache.cachePath(forComputedKey: key)
    }
    
    static let sharedCache = PhotoCache.shared.cache
}

private let cacheName = "Images"
private let prefixIdentifier = "com.xspyhack.History"

class CacheService {
    
    static let shared = CacheService()
    
    private let cache = ImageCache(name: cacheName, path: String.hi.documentsPath)
    
    private init() {
        cache.pathExtension = "png"
        cache.maxCachePeriodInSecond = -1 // never expiring
    }
    
    func store(_ image: UIImage, forKey key: String, completionHandler: (() -> Void)? = nil) {
        cache.store(image, forKey: key, toDisk: true, completionHandler: completionHandler)
    }
    
    func removeIfExisting(forKey key: String) {
        cache.removeImage(forKey: key, fromDisk: true, completionHandler: nil)
    }
    
    func retrieveImageInDiskCache(forKey key: String, scale: CGFloat = 1.0) -> UIImage? {
        return cache.retrieveImageInDiskCache(forKey: key, options: [.scaleFactor(scale)])
    }
    
    func filePath(forKey key: String) -> String {
        return cache.cachePath(forComputedKey: key)
    }
    
    static let sharedCache = CacheService.shared.cache
}
