//
//  ImageView+Cache.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Kingfisher
import Hikit

extension Hi where Base: UIImageView {
    
    func setImage(withURL URL: Foundation.URL?, placeholderImage: Image? = nil, progressBlock: DownloadProgressBlock? = nil, completionHandler: Kingfisher.CompletionHandler? = nil) -> RetrieveImageTask
    {
        var options: KingfisherOptionsInfo = []
        options.append(.TargetCache(ImageStorage.sharedCache))
        options.append(.Transition(.Fade(0.35)))
        options.append(.CacheMemoryOnly) // Don't cache second times

        return base.kf_setImageWithURL(URL,
                                  placeholderImage: placeholderImage,
                                  optionsInfo: options,
                                  progressBlock: progressBlock,
                                  completionHandler: completionHandler)
    }
    
}

extension X where Base: URL {
    
    static func imageURL(withPath path: String) -> URL {
        return URL(string: "http://blessingsoft.com/hi/images/" + path)!
    }
}
