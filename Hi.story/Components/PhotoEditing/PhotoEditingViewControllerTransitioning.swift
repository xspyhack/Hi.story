//
//  PhotoEditingViewControllerTransitioning.swift
//  PhotoEditing
//
//  Created by bl4ckra1sond3tre on 07/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class PhotoEditingViewControllerTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    /* State Tracking */
    var isDismissing: Bool = false // Whether this animation is presenting or dismissing
    var image: UIImage?    // The image that will be used in this animation
    
    /* Destination/Origin points */
    var fromView: UIView?  // The origin view who's frame the image will be animated from
    var toView: UIView?    // The destination view who's frame the image will animate to
    
    var fromFrame: CGRect = .zero  // An origin frame that the image will be animated from
    var toFrame: CGRect = .zero    // A destination frame the image will aniamte to
    
    /* A block called just before the transition to perform any last-second UI configuration */
    var prepareForTransitionHandler: (() -> Void)?
    
    /* Empties all of the properties in this object */
    func reset() {
        self.fromFrame = .zero
        self.toFrame = .zero
        self.toView = nil
        self.fromView = nil
        self.image = nil
        self.prepareForTransitionHandler = nil
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
       
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let cropViewController = isDismissing ? fromViewController : toViewController
        let previousViewController = isDismissing ? toViewController : fromViewController
        
        cropViewController?.view.frame = containerView.bounds
        if isDismissing {
            previousViewController?.view.frame = containerView.bounds
        }
        
        if isDismissing, let previousView = previousViewController?.view, let cropView = cropViewController?.view {
            containerView.insertSubview(previousView, belowSubview: cropView)
        } else if let cropView = cropViewController?.view {
            containerView.addSubview(cropView)
        }
        
        prepareForTransitionHandler?()
        
        if !isDismissing, let fromView = self.fromView {
            self.fromFrame = fromView.superview?.convert(fromView.frame, to: containerView) ?? .zero
        } else if isDismissing, let toView = self.toView {
            self.toFrame = toView.superview?.convert(toView.frame, to: containerView) ?? .zero
        }
        
        var imageView: UIImageView?
        if (isDismissing && !self.toFrame.isEmpty) || (!isDismissing && !self.fromFrame.isEmpty) {
            imageView = UIImageView(image: self.image)
            imageView?.frame = fromFrame
            containerView.addSubview(imageView!)
        }
        
        cropViewController?.view.alpha = isDismissing ? 1.0 : 0.0
        
        if let imageView = imageView {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: [], animations: {
                imageView.frame = self.toFrame
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.1, animations: { 
                    imageView.alpha = 0.0
                }, completion: { (finished) in
                    imageView.removeFromSuperview()
                })
            })
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            cropViewController?.view.alpha = self.isDismissing ? 0.0 : 1.0
        }, completion: { finished in
            self.reset()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
