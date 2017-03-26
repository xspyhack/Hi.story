//
//  PopoverPresentationController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 26/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

// ref: https://developer.apple.com/videos/play/wwdc2014/228/

struct PopoverPresentationShadow {
    let radius: CGFloat
    let color: UIColor
    let offset: CGSize
    
    init(radius: CGFloat = 12.0, color: UIColor = UIColor.black.withAlphaComponent(0.4), offset: CGSize = .zero) {
        self.radius = radius
        self.color = color
        self.offset = offset
    }
}

struct PopoverPresentationContext {
    let presentedContentSize: CGSize
    let cornerRadius: CGFloat
    let chromeAlpha: CGFloat
    let shadow: PopoverPresentationShadow?
    
    init(presentedContentSize size: CGSize, cornerRadius: CGFloat = 6.0, chromeAlpha: CGFloat = 0.6, shadow: PopoverPresentationShadow? = nil) {
        self.presentedContentSize = size
        self.cornerRadius = cornerRadius
        self.chromeAlpha = chromeAlpha
        self.shadow = shadow
    }
}

final class PopoverPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    
    private let presentationContext: PopoverPresentationContext
    
    private lazy var dimmingView: UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()
    
    /// just for shadow and corner
    /// shows shadow in background view
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.alpha = 0.0
        return view
    }()
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, presentationContext context: PopoverPresentationContext) {
        self.presentationContext = context
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setup(presented: presentedViewController)
    }
    
    private func setup(presented: UIViewController) {
        presented.view.layer.cornerRadius = presentationContext.cornerRadius
        presented.view.layer.masksToBounds = true
        
        if let shadow = presentationContext.shadow {
            backgroundView.layer.shadowColor = shadow.color.cgColor
            backgroundView.layer.shadowRadius = shadow.radius
            backgroundView.layer.shadowOffset = shadow.offset
            backgroundView.layer.masksToBounds = false
            backgroundView.layer.shadowOpacity = 1.0
        }
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        
        // Add the dimming view and the presented view to the heirarchy.
        containerView?.addSubview(dimmingView)
       
        if presentationContext.chromeAlpha <= 0.0 {
            dimmingView.backgroundColor = UIColor.clear
            dimmingView.alpha = 1.0
        }
        if presentationContext.shadow != nil {
            containerView?.addSubview(backgroundView)
            //backgroundView.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        }
        containerView?.addSubview(presentedView)
       
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { (context) -> Void in
            if self.presentationContext.chromeAlpha > 0.0 {
                self.dimmingView.alpha = self.presentationContext.chromeAlpha
            }
            
            if self.presentationContext.shadow != nil {
                //self.backgroundView.transform = .identity
                self.backgroundView.alpha = 1.0
            }
        }, completion: { (context) -> Void in
            //
        })
        
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PopoverPresentationController.handleTapDimmingView(_:))))
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        // If the presentation didn't complete, here should remove the dimming view.
        if !completed {
            dimmingView.removeFromSuperview()
            backgroundView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        backgroundView.alpha = 0.0
        
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { (context) -> Void in
            self.dimmingView.alpha = 0
            self.backgroundView.alpha = 0.0
        }, completion:nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // If the dismissal completed, here should remove the dimming view.
        if completed {
            dimmingView.removeFromSuperview()
            backgroundView.removeFromSuperview()
        }
    }
    
    // MARK: - Override
    
    override var frameOfPresentedViewInContainerView : CGRect {
        guard let containerView = containerView else { return CGRect() }
       
        var presentedViewFrame = CGRect.zero
        let containerBounds = containerView.bounds
        
        presentedViewFrame.size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        
        let center = CGPoint(x: containerBounds.origin.x + (containerBounds.width / 2.0),
                             y: containerBounds.origin.y + (containerBounds.height / 2.0))
        
        presentedViewFrame.origin = CGPoint(x: center.x - presentedViewFrame.width / 2.0, y: center.y - presentedViewFrame.height / 2.0)
        
        return presentedViewFrame
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentationContext.presentedContentSize
    }
   
    // Rotation support
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        guard let containerView = containerView else { return }
        
        dimmingView.frame = containerView.bounds
        
        let presentedViewFrame = frameOfPresentedViewInContainerView
        presentedView?.frame = presentedViewFrame
        
        if presentationContext.shadow != nil {
            backgroundView.frame = presentedViewFrame
            backgroundView.layer.shadowPath = UIBezierPath(rect: backgroundView.bounds).cgPath
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let containerView = containerView else { return }
        
        coordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView.frame = containerView.bounds
        }, completion:nil)
    }
    
    // MARK: - Event
    
    @objc private func handleTapDimmingView(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
