//
//  UIColor+Extension.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 10/8/15.
//  Copyright © 2015 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

// MARK: - Yep
extension UIColor {
    var yep_inverseColor: UIColor {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha)
    }
    
    var yep_binaryColor: UIColor {
        
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        
        return white > 0.92 ? UIColor.blackColor() : UIColor.whiteColor()
    }
    
    var yep_prettyColor: UIColor {
        return yep_binaryColor
    }
}

