//
//  NonStatusBarTransitionManager.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class NonStatusBarTransitionManager: NSObject {
    var duration: NSTimeInterval = 0.4
    
    enum TransitionType {
        case Present, Dismiss
    }
    
    var transitionType: TransitionType?
}

extension NonStatusBarTransitionManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if transitionType == .Present {
            animatePresentWithTransition(transitionContext)
        } else {
            animateDismissWithTransition(transitionContext)
        }
    }
    
    private func animatePresentWithTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else {
                return
        }
        
        containerView.addSubview(toViewController.view)
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.view.frame = finalFrame
        toViewController.view.center.y += containerView.bounds.height
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            toViewController.view.frame = finalFrame
        }) { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    private func animateDismissWithTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else {
                return
        }
        
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.view.frame = finalFrame
        toViewController.view.center.y += Defaults.statusBarHeight
        containerView.addSubview(toViewController.view)
        containerView.sendSubviewToBack(toViewController.view)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            fromViewController.view.center.y += containerView.bounds.height
        }) { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

extension NonStatusBarTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .Present
        
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .Dismiss
        
        return self
    }
}

