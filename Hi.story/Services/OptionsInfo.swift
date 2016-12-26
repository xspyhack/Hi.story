//
//  KingfisherOptionsInfo.swift
//  Kingfisher
//
//  Created by Wei Wang on 15/4/23.
//
//  Copyright (c) 2016 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/**
*	KingfisherOptionsInfo is a typealias for [KingfisherOptionsInfoItem]. You can use the enum of option item with value to control some behaviors of Kingfisher.
*/
public typealias OptionsInfo = [OptionsInfoItem]
let EmptyOptionsInfo = [OptionsInfoItem]()

/**
Items could be added into KingfisherOptionsInfo.
*/
public enum OptionsInfoItem {
    /// The associated value of this member should be an ImageCache object. Kingfisher will use the specified
    /// cache object when handling related operations, including trying to retrieve the cached images and store
    /// the downloaded image to it.
    case targetCache(ImageCache)
    
    /// Member for animation transition when using UIImageView. Kingfisher will use the `ImageTransition` of
    /// this enum to animate the image in if it is downloaded from web. The transition will not happen when the
    /// image is retrieved from either memory or disk cache by default. If you need to do the transition even when
    /// the image being retrieved from cache, set `ForceTransition` as well.
    case transition(ImageTransition)
    
    /// If set, `Kingfisher` will ignore the cache and try to fire a download task for the resource.
    case forceRefresh
    
    /// If set, setting the image to an image view will happen with transition even when retrieved from cache.
    /// See `Transition` option for more.
    case forceTransition
    
    ///  If set, `Kingfisher` will only cache the value in memory but not in disk.
    case cacheMemoryOnly
    
    /// If set, `Kingfisher` will only try to retrieve the image from cache not from network.
    case onlyFromCache
    
    /// Decode the image in background thread before using.
    case backgroundDecode
    
    /// The associated value of this member will be used as the target queue of dispatch callbacks when
    /// retrieving images from cache. If not set, `Kingfisher` will use main quese for callbacks.
    case callbackDispatchQueue(DispatchQueue?)
    
    /// The associated value of this member will be used as the scale factor when converting retrieved data to an image.
    case scaleFactor(CGFloat)
    
    /// Processor for processing when the downloading finishes, a processor will convert the downloaded data to an image
    /// and/or apply some filter on it. If a cache is connected to the downloader (it happenes when you are using
    /// KingfisherManager or the image extension methods), the converted image will also be sent to cache as well as the
    /// image view. `DefaultImageProcessor.default` will be used by default.
    case processor(ImageProcessor)
    
    /// Supply an `CacheSerializer` to convert some data to an image object for
    /// retrieving from disk cache or vice versa for storing to disk cache.
    /// `DefaultCacheSerializer.default` will be used by default.
    case cacheSerializer(CacheSerializer)
    
    /// Keep the existing image while setting another image to an image view.
    /// By setting this option, the placeholder image parameter of imageview extension method
    /// will be ignored and the current image will be kept while loading or downloading the new image.
    case keepCurrentImageWhileLoading
}

precedencegroup ItemComparisonPrecedence {
    associativity: none
    higherThan: LogicalConjunctionPrecedence
}

infix operator <== : ItemComparisonPrecedence

// This operator returns true if two `KingfisherOptionsInfoItem` enum is the same, without considering the associated values.
func <== (lhs: OptionsInfoItem, rhs: OptionsInfoItem) -> Bool {
    switch (lhs, rhs) {
    case (.targetCache(_), .targetCache(_)): return true
    case (.transition(_), .transition(_)): return true
    case (.forceRefresh, .forceRefresh): return true
    case (.forceTransition, .forceTransition): return true
    case (.cacheMemoryOnly, .cacheMemoryOnly): return true
    case (.onlyFromCache, .onlyFromCache): return true
    case (.backgroundDecode, .backgroundDecode): return true
    case (.callbackDispatchQueue(_), .callbackDispatchQueue(_)): return true
    case (.scaleFactor(_), .scaleFactor(_)): return true
    case (.processor(_), .processor(_)): return true
    case (.cacheSerializer(_), .cacheSerializer(_)): return true
    case (.keepCurrentImageWhileLoading, .keepCurrentImageWhileLoading): return true
    default: return false
    }
}

extension Collection where Iterator.Element == OptionsInfoItem {
    func firstMatchIgnoringAssociatedValue(_ target: Iterator.Element) -> Iterator.Element? {
        return index { $0 <== target }.flatMap { self[$0] }
    }
    
    func removeAllMatchesIgnoringAssociatedValue(_ target: Iterator.Element) -> [Iterator.Element] {
        return self.filter { !($0 <== target) }
    }
}

extension Collection where Iterator.Element == OptionsInfoItem {
    var targetCache: ImageCache {
        if let item = firstMatchIgnoringAssociatedValue(.targetCache(.default)),
            case .targetCache(let cache) = item
        {
            return cache
        }
        return ImageCache.default
    }
    
    var transition: ImageTransition {
        if let item = firstMatchIgnoringAssociatedValue(.transition(.none)),
            case .transition(let transition) = item
        {
            return transition
        }
        return ImageTransition.none
    }
    
    var forceRefresh: Bool {
        return contains{ $0 <== .forceRefresh }
    }
    
    var forceTransition: Bool {
        return contains{ $0 <== .forceTransition }
    }
    
    var cacheMemoryOnly: Bool {
        return contains{ $0 <== .cacheMemoryOnly }
    }
    
    var onlyFromCache: Bool {
        return contains{ $0 <== .onlyFromCache }
    }
    
    var backgroundDecode: Bool {
        return contains{ $0 <== .backgroundDecode }
    }
    
    var callbackDispatchQueue: DispatchQueue {
        if let item = firstMatchIgnoringAssociatedValue(.callbackDispatchQueue(nil)),
            case .callbackDispatchQueue(let queue) = item
        {
            return queue ?? DispatchQueue.main
        }
        return DispatchQueue.main
    }
    
    var scaleFactor: CGFloat {
        if let item = firstMatchIgnoringAssociatedValue(.scaleFactor(0)),
            case .scaleFactor(let scale) = item
        {
            return scale
        }
        return 1.0
    }
    
    var processor: ImageProcessor {
        if let item = firstMatchIgnoringAssociatedValue(.processor(DefaultImageProcessor.default)),
            case .processor(let processor) = item
        {
            return processor
        }
        return DefaultImageProcessor.default
    }
    
    var cacheSerializer: CacheSerializer {
        if let item = firstMatchIgnoringAssociatedValue(.cacheSerializer(DefaultCacheSerializer.default)),
            case .cacheSerializer(let cacheSerializer) = item
        {
            return cacheSerializer
        }
        return DefaultCacheSerializer.default
    }
    
    var keepCurrentImageWhileLoading: Bool {
        return contains { $0 <== .keepCurrentImageWhileLoading }
    }
}

/**
 Transition effect which will be used when an image downloaded and set by `UIImageView` extension API in Kingfisher.
 You can assign an enum value with transition duration as an item in `KingfisherOptionsInfo`
 to enable the animation transition.
 
 Apple's UIViewAnimationOptions is used under the hood.
 For custom transition, you should specified your own transition options, animations and
 comletion handler as well.
 */
public enum ImageTransition {
    ///  No animation transistion.
    case none
    
    /// Fade in the loaded image.
    case fade(TimeInterval)
    
    /// Flip from left transition.
    case flipFromLeft(TimeInterval)
    
    /// Flip from right transition.
    case flipFromRight(TimeInterval)
    
    /// Flip from top transition.
    case flipFromTop(TimeInterval)
    
    /// Flip from bottom transition.
    case flipFromBottom(TimeInterval)
    
    /// Custom transition.
    case custom(duration: TimeInterval,
        options: UIViewAnimationOptions,
        animations: ((UIImageView, UIImage) -> Void)?,
        completion: ((Bool) -> Void)?)
    
    var duration: TimeInterval {
        switch self {
        case .none:                          return 0
        case .fade(let duration):            return duration
            
        case .flipFromLeft(let duration):    return duration
        case .flipFromRight(let duration):   return duration
        case .flipFromTop(let duration):     return duration
        case .flipFromBottom(let duration):  return duration
            
        case .custom(let duration, _, _, _): return duration
        }
    }
    
    var animationOptions: UIViewAnimationOptions {
        switch self {
        case .none:                         return []
        case .fade(_):                      return .transitionCrossDissolve
            
        case .flipFromLeft(_):              return .transitionFlipFromLeft
        case .flipFromRight(_):             return .transitionFlipFromRight
        case .flipFromTop(_):               return .transitionFlipFromTop
        case .flipFromBottom(_):            return .transitionFlipFromBottom
            
        case .custom(_, let options, _, _): return options
        }
    }
    
    var animations: ((UIImageView, UIImage) -> Void)? {
        switch self {
        case .custom(_, _, let animations, _): return animations
        default: return { $0.image = $1 }
        }
    }
    
    var completion: ((Bool) -> Void)? {
        switch self {
        case .custom(_, _, _, let completion): return completion
        default: return nil
        }
    }
}
