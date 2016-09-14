//
//  Cache.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Kingfisher

class Cache {
    
    static let shareCache = Cache()
    
//    func saveImage(image: UIImage, forURL url: NSURL) -> String {
//        Kingfisher.ImageCache.defaultCache.storeImage(image, forKey: url.absoluteString, toDisk: true) {
//            //
//        }
//        
//        return Kingfisher.ImageCache.defaultCache.cachePathForKey(url.absoluteString)
//    }
//    
//    func removeImage(forURL url: NSURL) {
//        Kingfisher.ImageCache.defaultCache.removeImageForKey(url.absoluteString, fromDisk: true) { 
//            print("removed cache")
//        }
//    }
//    
//    func tryToRemoveImage(forURL url: NSURL) {
//        if cacheExists(forURL: url) {
//            removeImage(forURL: url)
//        }
//    }
//    
//    func cacheExists(forURL url: NSURL) -> Bool {
//        return Kingfisher.ImageCache.defaultCache.cachedImageExistsforURL(url)
//    }
    
    
}

private let cacheName = "Images"
private let prefixIdentifier = "com.xspyhack.History"

class ImageStorage {
    
    static let sharedStorage = ImageStorage()
    
    fileprivate let cache = ImageCache(name: cacheName, path: String.hi_documentsPath)
    
    func storeImage(_ image: Image, forKey key: String, completionHandler: (() -> Void)? = nil) {
        
        cache.storeImage(image, forKey: key, toDisk: true, completionHandler: completionHandler)
    }
    
    func retrieveImageInDiskCacheForKey(_ key: String, scale: CGFloat = 1.0) -> Image? {
        return cache.retrieveImageInDiskCacheForKey(key, scale: scale)
    }
    
    static let sharedCache = ImageStorage.sharedStorage.cache
}
