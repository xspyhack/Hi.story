//
//  UIImage+Assets.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 19/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension Hi where Base: UIImage {
    
    static var navBack: UIImage? {
        return UIImage(named: "nav_back")
    }
    
    static var avatar: UIImage? {
        return UIImage(named: "avatar")
    }
    
    static func roundedAvatar(radius: CGFloat) -> UIImage? {
        return avatar?.hi.image(withRoundRadius: radius, fit: CGSize(width: radius * 2, height: radius * 2))
    }
}
