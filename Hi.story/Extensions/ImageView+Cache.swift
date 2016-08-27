//
//  ImageView+Cache.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func kf_setImage(withURL URL: NSURL?, placeholderImage: Image? = nil, progressBlock: DownloadProgressBlock? = nil, completionHandler: Kingfisher.CompletionHandler? = nil) -> RetrieveImageTask
    {
        var options: KingfisherOptionsInfo = []
        options.append(.TargetCache(ImageStorage.sharedCache))
        options.append(.Transition(.Fade(0.35)))
        options.append(.CacheMemoryOnly) // Don't cache second times

        return kf_setImageWithURL(URL,
                                  placeholderImage: placeholderImage,
                                  optionsInfo: options,
                                  progressBlock: progressBlock,
                                  completionHandler: completionHandler)
    }
    
}

extension NSURL {
    
    static func hi_imageURL(withPath path: String) -> NSURL {
        return NSURL(string: "http://blessingsoft.com/hi/images/" + path)!
    }
}