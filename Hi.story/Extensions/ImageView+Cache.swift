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

extension Hi where Base == URL {
    
    static func imageURL(withPath path: String) -> URL {
        return URL(string: "https://blessingsoft.com/hi/images/" + path)!
    }
}

public struct URLProxy {
    public let base: URL
    public init(_ base: URL) {
        self.base = base
    }
}

extension URL: HistoryCompatible {
}
