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
    @objc optional func transitionDidComplete(_ transitionType: TransitionType)
}

protocol PresentedControllerDelegate: class {
    func destinationFrame() -> CGRect
    func destinationImage() -> UIImage?
}

@objc enum TransitionType: Int {
    case present, dismiss
}

class ImagePreviewTransitionManager: NSObject {
    var duration: TimeInterval = 0.4
    
    weak var presentedDelegate: PresentedControllerDelegate?
    weak var presentingDelegate: PresentingControllerDelegate?
    
    var transitionType: TransitionType?
}

extension ImagePreviewTransitionManager: UIViewControllerAnimatedTransitioning {
    
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
        
        guard let presentingDelegate = presentingDelegate, let presentedDelegate = presentedDelegate else {
            assert(false, "Must set PresentedControllerDelegate & PresentingControllerDelegate")
            return
        }
        
        let containerView = transitionContext.containerView
        let toView = toViewController.view
        containerView.addSubview(toView!)
        containerView.bringSubview(toFront: toView!)
        
        let sourceImageView = presentingDelegate.sourceImageView()
        
        let original = sourceImageView.convert(CGPoint.zero, to: nil)
        let coverImageView = UIImageView(frame: CGRect(origin: original, size: sourceImageView.bounds.size))
        
        coverImageView.contentMode = .scaleAspectFit
        coverImageView.image = sourceImageView.image
        containerView.addSubview(coverImageView)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        toView?.frame = finalFrame
        toView?.alpha = 0.0
        
        UIView.animate(withDuration: duration, animations: { 
            toView?.alpha = 1.0
            let destinationFrame = presentedDelegate.destinationFrame()
            coverImageView.frame = destinationFrame
            
        }, completion: { (finished) in
            coverImageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
    
    private func dismissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return
        }
        
        guard let presentingDelegate = presentingDelegate, let presentedDelegate = presentedDelegate else {
            assert(false, "Must set PresentedControllerDelegate & PresentingControllerDelegate")
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.sendSubview(toBack: toView)
        
        let destinationImage = presentedDelegate.destinationImage()
        let coverImageView = UIImageView(frame: presentedDelegate.destinationFrame())
        
        coverImageView.contentMode = .scaleAspectFit
        coverImageView.image = destinationImage
        containerView.addSubview(coverImageView)
        
        UIView.animate(withDuration: duration - 0.1, animations: { () -> Void in
            fromViewController.view.alpha = 0.0
            coverImageView.frame = presentingDelegate.sourceFrame()
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.1, animations: {
                toView.alpha = 1.0
            }, completion: { (finished) -> Void in
                coverImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }) 
        }) 
    }
}

extension ImagePreviewTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transitionType = .present
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transitionType = .dismiss
        return self
    }
}

