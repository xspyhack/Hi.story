//
//  UIStoryBoard+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension UIStoryboard {
    
    enum Storyboard: String {
        case main
        
        case matter
        
        var value: String {
            return self.rawValue.capitalized
        }
    }
}

extension X where Base: UIStoryboard {
    
    static func storyboard(_ board: UIStoryboard.Storyboard) -> UIStoryboard {
        
        return UIStoryboard(name: board.value, bundle: nil)
    }
    
}
