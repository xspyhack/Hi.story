//
//  Kingfisher+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 30/09/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Kingfisher

enum Transformer {
    case rounded(CGSize)
    case resizing(CGSize)
    case none
}

extension ImageView {
    
    @discardableResult
    func setImage(with resource: Resource?,
                  placeholder: UIImage? = nil,
                  transformer: Transformer = .none,
                  completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.3)),
            .backgroundDecode,
            .targetCache(CacheService.sharedCache),
            .cacheMemoryOnly, // Don't cache second times
            .scaleFactor(UIScreen.main.scale),
        ]
        
        switch transformer {
        case .rounded(let targetSize):
            let processor: RoundCornerImageProcessor = RoundCornerImageProcessor(cornerRadius: targetSize.width / 2.0, targetSize: targetSize)
            options.append(.processor(processor))
            
            let serializer = RoundedCacheSerializer.shared
            options.append(.cacheSerializer(serializer))
        case .resizing(let targetSize):
            let processor = ResizingImageProcessor(targetSize: targetSize)
            options.append(.processor(processor))
        case .none:
            break
        }
        
        return self.kf.setImage(with: resource, placeholder: placeholder, options: options, progressBlock: nil, completionHandler: completionHandler)
    }
}

extension UIButton {
   
    @discardableResult
    func setImage(with resource: Resource?,
                  for state: UIControlState,
                  placeholder: UIImage? = nil,
                  transformer: Transformer = .none,
                  completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.3)),
            .backgroundDecode,
            .targetCache(CacheService.sharedCache),
            .cacheMemoryOnly, // Don't cache second times
            .scaleFactor(UIScreen.main.scale),
        ]
        
        switch transformer {
        case .rounded(let targetSize):
            let processor: RoundCornerImageProcessor = RoundCornerImageProcessor(cornerRadius: targetSize.width / 2.0, targetSize: targetSize)
            options.append(.processor(processor))
            
            let serializer = RoundedCacheSerializer.shared
            options.append(.cacheSerializer(serializer))
        case .resizing(let targetSize):
            let processor = ResizingImageProcessor(targetSize: targetSize)
            options.append(.processor(processor))
        case .none:
            break
        }
        
        return self.kf.setImage(with: resource, for: state, placeholder: placeholder, options: options, progressBlock: nil, completionHandler: completionHandler)
    }
    
    @discardableResult
    func setBackgroundImage(with resource: Resource?,
                  for state: UIControlState,
                  placeholder: UIImage? = nil,
                  transformer: Transformer = .none,
                  completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.3)),
            .backgroundDecode,
            .targetCache(CacheService.sharedCache),
            .cacheMemoryOnly, // Don't cache second times
            .scaleFactor(UIScreen.main.scale),
            ]
        
        switch transformer {
        case .rounded(let targetSize):
            let processor: RoundCornerImageProcessor = RoundCornerImageProcessor(cornerRadius: targetSize.width / 2.0, targetSize: targetSize)
            options.append(.processor(processor))
            
            let serializer = RoundedCacheSerializer.shared
            options.append(.cacheSerializer(serializer))
        case .resizing(let targetSize):
            let processor = ResizingImageProcessor(targetSize: targetSize)
            options.append(.processor(processor))
        case .none:
            break
        }
        
        return self.kf.setBackgroundImage(with: resource, for: state, placeholder: placeholder, options: options, progressBlock: nil, completionHandler: completionHandler)
    }
}

// just for jpeg image corner bug

public struct RoundedCacheSerializer: CacheSerializer {
    
    public static let shared = RoundedCacheSerializer()
    private init() {}
    
    public func data(with image: Image, original: Data?) -> Data? {
        
        let data: Data? = UIImagePNGRepresentation(image)
        
        return data
    }
    
    public func image(with data: Data, options: KingfisherOptionsInfo?) -> Image? {
        
        var scale: CGFloat? = 1.0
        
        if let options = options {
            
            scale = options.flatMap { (item) -> CGFloat? in
                if case .scaleFactor(let scale) = item {
                    return scale
                } else {
                    return 1.0
                }
            }.first
        }
        
        return Image(data: data, scale: scale ?? 1.0)
    }
}
