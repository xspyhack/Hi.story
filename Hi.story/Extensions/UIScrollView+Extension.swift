//
//  UIScrollView+Extension.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/4/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func xh_isAtTop() -> Bool {
        return contentOffset.y == -contentInset.top
    }
    
    func xh_scrollToTop(animated aimate: Bool = true) {
        let topPoint = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topPoint, animated: aimate)
    }
    
    func xh_forceStop() {
        //scrollEnabled = false
        //scrollEnabled = true
        
        setContentOffset(contentOffset, animated: false)
    }
}