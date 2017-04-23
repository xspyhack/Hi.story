//
//  PhotoCacheController.swift
//  Yep
//
//  Created by nixzhu on 15/10/14.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import Foundation
import Photos

final class ImageCacheController {

    private var cachedIndices = NSIndexSet()
    private let cachePreheatSize: Int
    private let imageCache: PHCachingImageManager
    private let images: PHFetchResult<PHAsset>
    private let targetSize = CGSize(width: 80, height: 80)
    private let contentMode = PHImageContentMode.aspectFill

    init(imageManager: PHCachingImageManager, images: PHFetchResult<PHAsset>, preheatSize: Int = 1) {
        self.cachePreheatSize = preheatSize
        self.imageCache = imageManager
        self.images = images
    }

    func updateVisibleCells(at indexPaths: [IndexPath]) {

        guard !indexPaths.isEmpty else {
            return
        }

        let updatedCache = NSMutableIndexSet()
        for path in indexPaths {
            updatedCache.add(path.item)
        }

        let minCache = max(0, updatedCache.firstIndex - cachePreheatSize)
        let maxCache = min(images.count - 1, updatedCache.lastIndex + cachePreheatSize)

        updatedCache.add(in: NSMakeRange(minCache, maxCache - minCache + 1))

        // Which indices can be chucked?
        cachedIndices.enumerated().forEach { (index, _) in
            if !updatedCache.contains(index) {
                let asset: PHAsset! = self.images[index]
                self.imageCache.stopCachingImages(for: [asset], targetSize: self.targetSize, contentMode: self.contentMode, options: nil)
            }
        }
        // And which are new?
        updatedCache.enumerated().forEach { (index, _) in
            if !self.cachedIndices.contains(index) {
                let asset: PHAsset = self.images[index]
                self.imageCache.startCachingImages(for: [asset], targetSize: self.targetSize, contentMode: self.contentMode, options: nil)
            }
        }

        cachedIndices = updatedCache
    }
    
    // MARK: Asset Caching
    
    func resetCachedAssets() {
        imageCache.stopCachingImagesForAllAssets()
    }
}

