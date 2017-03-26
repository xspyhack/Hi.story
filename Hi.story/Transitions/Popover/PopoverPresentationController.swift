//
//  PopoverPresentationController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 26/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

// ref: https://developer.apple.com/videos/play/wwdc2014/228/

struct PopoverPresentationContext {
    let size: CGSize
    let cornerRadius: CGFloat
    let showsShadow: Bool
}

final class PopoverPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    
    private let presentationContext: PopoverPresentationContext
    
    private lazy var dimmingView: UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, presentationContext context: PopoverPresentationContext) {
        self.presentationContext = context
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        
        // Add the dimming view and the presented view to the heirarchy.
        containerView?.addSubview(dimmingView)
        containerView?.addSubview(presentedView)
        
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { (context) -> Void in
            self.dimmingView.alpha = 0.6
        }, completion: { (context) -> Void in
            //
        })
        
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDimmingView(_:))))
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        // If the presentation didn't complete, here should remove the dimming view.
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { (context) -> Void in
            self.dimmingView.alpha = 0
        }, completion:nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // If the dismissal completed, here should remove the dimming view.
        if completed {
            dimmingView.removeFromSuperview()
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
        return presentationContext.size
    }
   
    // Rotation support
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        guard let containerView = containerView else { return }
        
        dimmingView.frame = containerView.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
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
