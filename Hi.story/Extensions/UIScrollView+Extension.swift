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
        let topOffset = CGPoint(x: 0, y: -base.contentInset.top)
        base.setContentOffset(topOffset, animated: aimate)
    }
    
    func scrollToBottom(animated animate: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: max(0, base.contentSize.height - base.bounds.height))
        base.setContentOffset(bottomOffset, animated: true)
    }
    
    func forceStop() {
        //scrollEnabled = false
        //scrollEnabled = true
        
        base.setContentOffset(base.contentOffset, animated: false)
    }
}
