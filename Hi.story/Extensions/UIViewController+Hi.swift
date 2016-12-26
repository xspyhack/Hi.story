//
//  UIViewController+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 09/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension UIViewController: Identifiable {
    var identifier: String {
        return String(describing: self)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func instantiate(from storyboard: Storyboard) -> Self {
        return storyboard.viewController(of: self)
    }
}
