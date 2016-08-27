//
//  PresentationController.swift
//  Viewer
//
//  Created by bl4ckra1sond3tre on 3/9/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {
    
    var presentedViewHeight: CGFloat = Defaults.presentedViewControllerHeight
    
    lazy var dimmingView: UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor.blackColor()
        view.alpha = 0.0
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView() else { return }
        
        // Add the dimming view and the presented view to the heirarchy.
        containerView?.addSubview(dimmingView)
        containerView?.addSubview(presentedView)
        
        let transitionCoordinator = presentingViewController.transitionCoordinator()
        transitionCoordinator?.animateAlongsideTransition({ (context) -> Void in
            self.dimmingView.alpha = 0.6
            }, completion: { (context) -> Void in
                //
        })
        
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDimmingView(_:))))
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        // If the presentation didn't complete, here should remove the dimming view.
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator()
        transitionCoordinator?.animateAlongsideTransition({ (context) -> Void in
            self.dimmingView.alpha = 0
            }, completion:nil)
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        // If the dismissal completed, here should remove the dimming view.
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    // MARK: -
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        guard let containerView = containerView else { return CGRect() }
        
        return CGRect(x: 0, y: containerView.bounds.height - presentedViewHeight, width: containerView.bounds.width, height: presentedViewHeight)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        guard let containerView = containerView else { return }
        
        coordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView.frame = containerView.bounds
            }, completion:nil)
    }
    
    // MARK: - Event
    
    @objc private func handleTapDimmingView(sender: UITapGestureRecognizer) {
        presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
