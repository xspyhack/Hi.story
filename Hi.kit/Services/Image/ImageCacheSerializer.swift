//
//  ImageCacheSerializer.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hicache

public struct ImageCacheSerializer: CacheSerializer {
    
    public func data(with object: UIImage, original: Data?) -> Data? {
        // just for jpeg image corner bug
        // UIImageJPGRepresentation(object, 0.9)
        return UIImagePNGRepresentation(object)
    }
    
    public func object(with data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
