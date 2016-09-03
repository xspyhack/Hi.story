//
//  UIColor+Hi.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public convenience init(r: Int, g: Int, b: Int, a: Int) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 100.0)
    }
    
    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if hex.hasPrefix("#") {
            hex = (hex as NSString).substringFromIndex(1)
        }
        
        if hex.characters.count != 6 {
            fatalError()
        }
        
        var rgbValue: UInt32 = 0
        let scanner = NSScanner.init(string: hex)
        scanner.scanLocation = 0
        scanner.scanHexInt(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension X where Base: UIColor {
    
    public static var textColor: UIColor {
        return UIColor(hex: "#363636")
    }
    
    public static var lightTextColor: UIColor {
        return UIColor(hex: "#8F8F8F")
    }
    public static var placeholderColor: UIColor {
        return UIColor(hex: "#C7C7C7")
    }
    
    public static var titleColor: UIColor {
        return UIColor(hex: "#1F1F1F")
    }
}

