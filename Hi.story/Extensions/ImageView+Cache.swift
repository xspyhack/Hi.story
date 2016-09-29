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

extension ImageView {
    
    @discardableResult
    func setImage(with url: URL?, placeholderImage: Image? = nil, progressBlock: DownloadProgressBlock? = nil, completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        var options: KingfisherOptionsInfo = []
        options.append(.targetCache(ImageStorage.sharedCache))
        options.append(.transition(.fade(0.35)))
        options.append(.cacheMemoryOnly) // Don't cache second times
        
        return kf.setImage(with: url,
                                placeholder: placeholderImage,
                                options: options,
                                progressBlock: progressBlock,
                                completionHandler: completionHandler)
    }
}

extension Hi where Base: UIImageView {
    
}

extension X where Base: NSURL {
    
    static func imageURL(withPath path: String) -> URL {
        return URL(string: "http://blessingsoft.com/hi/images/" + path)!
    }
}
