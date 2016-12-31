//
//  UIMotionEffect+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

extension UIInterpolatingMotionEffectType {
    
    var centerKeyPath: String {
        switch self {
        case .tiltAlongHorizontalAxis:
            return "center.x"
        case .tiltAlongVerticalAxis:
            return "center.y"
        }
    }
}

extension Hi where Base: UIMotionEffect {
    
    static func twoAxiesShift(_ strength: Float) -> UIMotionEffect {
        
        func motion(_ type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let keyPath = type.centerKeyPath
            let motion = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
            motion.minimumRelativeValue = -strength
            motion.maximumRelativeValue = strength
            return motion
        }
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [
            motion(.tiltAlongHorizontalAxis),
            motion(.tiltAlongVerticalAxis),
        ]
        return group
    }
}

