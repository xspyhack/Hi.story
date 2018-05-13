//
//  PresentationTransitionManager.swift
//  Viewer
//
//  Created by bl4ckra1sond3tre on 3/9/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol PresentationRepresentation {
    
    var presentationTransition: PresentationTransitionManager { get }
}

struct PresentationContext {
    let presentedContentSize: CGSize
    let cornerRadius: CGFloat
    let chromeAlpha: CGFloat
    let contentInset: UIEdgeInsets
    let offset: CGPoint

    init(presentedContentSize size: CGSize, cornerRadius: CGFloat = 0.0, chromeAlpha: CGFloat = 0.6, contentInset: UIEdgeInsets = .zero, offset: CGPoint = .zero) {
        self.presentedContentSize = size
        self.cornerRadius = cornerRadius
        self.chromeAlpha = chromeAlpha
        self.contentInset = contentInset
        self.offset = offset
    }
}

final class PresentationTransitionManager: NSObject {
    
    var duration: TimeInterval = 0.4

    var presentationContext: PresentationContext
    
    enum TransitionType {
        case present, dismiss
    }

    private var transitionType: TransitionType?

    init(context: PresentationContext) {
        self.presentationContext = context
    }
}

extension PresentationTransitionManager: UIViewControllerAnimatedTransitioning {

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
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .allowUserInteraction, animations: { () -> Void in
            toViewController.view.frame = finalFrame
            toViewController.view.center.y += self.presentationContext.offset.y
            toViewController.view.center.x += self.presentationContext.offset.x
            
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    private func dismissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        UIView.animate(withDuration: duration, animations: { () -> Void in
            fromViewController.view.center.y += containerView.bounds.height
            
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
}

extension PresentationTransitionManager: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting, context: presentationContext)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .present
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .dismiss
        return self
    }
}

