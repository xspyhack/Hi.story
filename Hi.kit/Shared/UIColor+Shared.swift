//
//  UIColor+Shared.swift
//  Hi.kit`
//
//  Created by bl4ckra1sond3tre on 11/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public convenience init(r: Int, g: Int, b: Int, a: Int) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 100.0)
    }
    
    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if hex.hasPrefix("#") {
            hex = (hex as NSString).substring(from: 1)
        }
        
        if hex.count != 6 {
            //fatalError()
            // clear color
            self.init(white: 0.0, alpha: 0.0)
        } else {
            var rgbValue: UInt32 = 0
            let scanner = Scanner.init(string: hex)
            scanner.scanLocation = 0
            scanner.scanHexInt32(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0xFF) / 255.0
            
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
        
    }
}
