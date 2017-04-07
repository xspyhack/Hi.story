//
//  UIView+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 19/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension Hi where Base: UIView {
    
    func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, 0)
        base.layer.affineTransform()
        base.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Gradient

typealias GradientPoints = (start: CGPoint, end: CGPoint)

enum GradientOrientation {
    
    case horizontal
    case vertical
    
    var startPoint : CGPoint {
        get { return points.start }
    }
    
    var endPoint : CGPoint {
        get { return points.end }
    }
    
    var points : GradientPoints {
        get {
            switch(self) {
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.5,y: 0.0), CGPoint(x: 0.5,y: 1.0))
            }
        }
    }
}

private var gradientKey: Void?

extension Hi where Base: UIView {
    
    var gradient: CAGradientLayer? {
        return objc_getAssociatedObject(base, &gradientKey) as? CAGradientLayer
    }
    
    func setGradient(_ gradient: CAGradientLayer) {
        objc_setAssociatedObject(base, &gradientKey, gradient, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func apply(_ colors: [UIColor], locations: [NSNumber]? = nil, orientation: GradientOrientation = .horizontal) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.frame = self.base.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        
        setGradient(gradient)
        
        self.base.layer.insertSublayer(gradient, at: 0)
    }
}
