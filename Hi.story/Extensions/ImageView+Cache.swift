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

extension X where Base: NSURL {
    
    static func imageURL(withPath path: String) -> URL {
        return URL(string: "http://blessingsoft.com/hi/images/" + path)!
    }
}
