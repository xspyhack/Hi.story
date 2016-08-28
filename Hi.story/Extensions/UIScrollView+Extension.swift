//
//  UIScrollView+Extension.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/4/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension Hi where Base: UIScrollView {
    
    func isAtTop() -> Bool {
        return base.contentOffset.y == -base.contentInset.top
    }
    
    func scrollToTop(animated aimate: Bool = true) {
        let topPoint = CGPoint(x: 0, y: -base.contentInset.top)
        base.setContentOffset(topPoint, animated: aimate)
    }
    
    func forceStop() {
        //scrollEnabled = false
        //scrollEnabled = true
        
        base.setContentOffset(base.contentOffset, animated: false)
    }
}