//
//  NonStatusBarTransitionManager.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class NonStatusBarTransitionManager: NSObject {
    var duration: TimeInterval = 0.4
    
    enum TransitionType {
        case present, dismiss
    }
    
    var transitionType: TransitionType?
}

extension NonStatusBarTransitionManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionType == .present {
            presentTransition(using: transitionContext)
        } else {
            dismissalTransition(using: transitionContext)
        }
    }
    
    private func presentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toViewController.view)
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = finalFrame
        toViewController.view.center.y += containerView.bounds.height
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            toViewController.view.frame = finalFrame
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
    
    private func dismissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = finalFrame
        toViewController.view.center.y += Defaults.statusBarHeight
        containerView.addSubview(toViewController.view)
        containerView.sendSubview(toBack: toViewController.view)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            fromViewController.view.center.y += containerView.bounds.height
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
}

extension NonStatusBarTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transitionType = .present
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transitionType = .dismiss
        return self
    }
}

