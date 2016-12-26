//
//  UIView+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 19/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension Hi where Base: UIView {
    
    func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, 0)
        base.layer.affineTransform()
        base.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
