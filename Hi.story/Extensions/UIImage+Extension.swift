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
        
        let rgba = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context: CGContext = CGContext(data: rgba, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: info.rawValue)!
        
        context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        let alpha: CGFloat = (rgba[3] > 0) ? (CGFloat(rgba[3]) / 255.0) : 1
        let multiplier = alpha / 255.0
        
        return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
    }
}
