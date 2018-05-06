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
    
    var isAtTop: Bool {
        return base.contentOffset.y == -base.contentInset.top
    }
    
    func scrollsToTop(animated: Bool = true) {

        let offset: CGFloat
        if #available(iOS 11.0, *) {
            offset = base.adjustedContentInset.top
        } else {
            offset = base.contentInset.top
        }

        let topOffset = CGPoint(x: 0, y: -offset)
        base.setContentOffset(topOffset, animated: animated)
    }
    
    func scrollsToBottom(animated: Bool = true) {
        let offset: CGFloat
        if #available(iOS 11.0, *) {
            offset = base.adjustedContentInset.bottom
        } else {
            offset = base.contentInset.bottom
        }

        let bottomOffset = CGPoint(x: 0, y: max(0, base.contentSize.height - base.bounds.height + offset))
        base.setContentOffset(bottomOffset, animated: animated)
    }
    
    func forcesStop() {
        //scrollEnabled = false
        //scrollEnabled = true
        if #available(iOS 11.0, *) {

        } else {

        }
        base.setContentOffset(base.contentOffset, animated: false)
    }
}
