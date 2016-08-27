//
//  UIImage+Extension.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

// MARK: - Yep

extension UIImage {
    
    var yep_avarageColor: UIColor {
        
        let rgba = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context: CGContextRef = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, info.rawValue)!
        
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), CGImage)
        
        let alpha: CGFloat = (rgba[3] > 0) ? (CGFloat(rgba[3]) / 255.0) : 1
        let multiplier = alpha / 255.0
        
        return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
    }
}