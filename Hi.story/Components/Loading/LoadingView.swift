//
//  LoadingView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 19/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    lazy var gradientLayer: CAGradientLayer = {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let colors = [
            UIColor.gray.cgColor,
            UIColor.hi.tint.cgColor,
            UIColor.gray.cgColor,
        ]
        gradientLayer.colors = colors
        
        let locations: [NSNumber] = [0.25, 0.5, 0.75]
        gradientLayer.locations = locations
        
        return gradientLayer
    }()
    
    lazy var textAttributes: [String: AnyObject] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        return [
            NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 28.0)!,
            NSParagraphStyleAttributeName:style
        ]
    }()
    
    @IBInspectable var text: String! {
        didSet {
            setNeedsDisplay()
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
            text.draw(in: bounds, withAttributes: textAttributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.frame = bounds.offsetBy(dx: bounds.size.width, dy: 0)
            maskLayer.contents = image?.cgImage
            
            gradientLayer.mask = maskLayer
        }
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: bounds.origin.y, width: 3 * bounds.size.width, height: bounds.size.height)
        
        layer.addSublayer(gradientLayer)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.75, 1.0, 1.0]
        
        gradientAnimation.duration = 3.0
        gradientAnimation.repeatCount = Float.infinity
        gradientLayer.add(gradientAnimation, forKey: nil)
    }
}
