//
//  UIColor+Hi.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

public extension Hi where Base: UIColor {
    
    public static var tint: UIColor {
        return UIColor(hex: "#1BBBBB")
    }
    
    public static var text: UIColor {
        return UIColor(hex: "#4A4A4A")
    }
    
    public static var lightText: UIColor {
        return UIColor(hex: "#8F8F8F")
    }
    
    public static var description: UIColor {
        return UIColor(hex: "#8F8F8F")
    }
    
    public static var emptyText: UIColor {
        return UIColor(hex: "#A0A0A0")
    }
    
    public static var placeholder: UIColor {
        return UIColor(hex: "#C7C7C7")
    }
    
    public static var title: UIColor {
        return UIColor(hex: "#2F2F2F")
    }
    
    public static var body: UIColor {
        return UIColor(hex: "#7D7D7D")
    }
    
    public static var detail: UIColor {
        return UIColor(hex: "#7D7D7D")
    }
    
    public static var border: UIColor {
        return UIColor(hex: "#EEEEEE")
    }
    
    public static var separator: UIColor {
        return UIColor(hex: "#DDDDDD")
    }
    
    public static var background: UIColor {
        return UIColor(hex: "#F7F7F7")
    }
    
}

public extension Hi where Base: UIColor {
    
    public var hex: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard base.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}

