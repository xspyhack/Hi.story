//
//  PopoverTransitioningDelegate.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 26/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class PopoverTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let presentationContext: PopoverPresentationContext
    
    init(presentationContext: PopoverPresentationContext) {
        self.presentationContext = presentationContext
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PopoverPresentationController(presentedViewController: presented, presenting: presenting, presentationContext: presentationContext)
    }
}
