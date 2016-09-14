//
//  UIView+Protocol.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/21/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol Shakeable {
    
}

extension Shakeable where Self: UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 6
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 4.0, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 4.0, y: center.y))
        layer.add(animation, forKey: "shake")
    }
    
}

protocol Scaleable {
    var value: CGFloat { get }
}

extension Scaleable where Self: UIView {
    var value: CGFloat { return 0.6 }
    func scale() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.05
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = NSNumber(value: 1.0 as Float)
        animation.toValue = NSNumber(value: Float(value) as Float)
        layer.add(animation, forKey: "scale")
    }
}

protocol Maskable {
    
}

extension Scaleable where Self: UIView {
    
}
