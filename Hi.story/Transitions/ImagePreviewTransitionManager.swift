//
//  ImagePreviewTransitionManager.swift
//  Dribbbiu
//
//  Created by bl4ckra1sond3tre on 5/13/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

@objc protocol PresentingControllerDelegate {
    func sourceImageView() -> UIImageView
    func sourceFrame() -> CGRect
    optional func transitionDidComplete(transitionType: TransitionType)
}

protocol PresentedControllerDelegate: class {
    func destinationFrame() -> CGRect
    func destinationImage() -> UIImage?
}

@objc enum TransitionType: Int {
    case Present, Dismiss
}

class ImagePreviewTransitionManager: NSObject {
    var duration: NSTimeInterval = 0.4
    
    weak var presentedDelegate: PresentedControllerDelegate?
    weak var presentingDelegate: PresentingControllerDelegate?
    
    var transitionType: TransitionType?
}

extension ImagePreviewTransitionManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if transitionType == .Present {
            presentWithAnimateTransition(transitionContext)
        } else {
            dismissWithAnmatedTransition(transitionContext)
        }
    }
    
    private func presentWithAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else {
                return
        }
        
        guard let presentingDelegate = presentingDelegate, presentedDelegate = presentedDelegate else {
            assert(false, "Must set PresentedControllerDelegate & PresentingControllerDelegate")
            return
        }
        
        let toView = toViewController.view
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)
        
        let sourceImageView = presentingDelegate.sourceImageView()
        
        let original = sourceImageView.convertPoint(CGPoint.zero, toView: nil)
        let coverImageView = UIImageView(frame: CGRect(origin: original, size: sourceImageView.bounds.size))
        
        coverImageView.contentMode = .ScaleAspectFit
        coverImageView.image = sourceImageView.image
        containerView.addSubview(coverImageView)
        
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        
        toView.frame = finalFrame
        toView.alpha = 0.0
        
        UIView.animateWithDuration(duration, animations: { 
            toView.alpha = 1.0
            let destinationFrame = presentedDelegate.destinationFrame()
            coverImageView.frame = destinationFrame
            
        }) { (finished) in
            coverImageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    private func dismissWithAnmatedTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            else {
                return
        }
        
        guard let presentingDelegate = presentingDelegate, presentedDelegate = presentedDelegate else {
            assert(false, "Must set PresentedControllerDelegate & PresentingControllerDelegate")
            return
        }
        
        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)
        
        let destinationImage = presentedDelegate.destinationImage()
        let coverImageView = UIImageView(frame: presentedDelegate.destinationFrame())
        
        coverImageView.contentMode = .ScaleAspectFit
        coverImageView.image = destinationImage
        containerView.addSubview(coverImageView)
        
        UIView.animateWithDuration(duration - 0.1, animations: { () -> Void in
            fromViewController.view.alpha = 0.0
            coverImageView.frame = presentingDelegate.sourceFrame()
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.1, animations: {
                toView.alpha = 1.0
            }) { (finished) -> Void in
                coverImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        }
    }
}

extension ImagePreviewTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .Present
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .Dismiss
        
        return self
    }
}

