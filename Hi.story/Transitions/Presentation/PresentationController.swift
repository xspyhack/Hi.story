//
//  PresentationController.swift
//  Viewer
//
//  Created by bl4ckra1sond3tre on 3/9/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {

    let context: PresentationContext
    
    lazy var dimmingView: UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, context: PresentationContext) {
        self.context = context

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        
        // Add the dimming view and the presented view to the heirarchy.
        containerView?.addSubview(dimmingView)
        containerView?.addSubview(presentedView)
        
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { (context) -> Void in
            self.dimmingView.alpha = self.context.chromeAlpha
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
    
    // MARK: -
    
    override var frameOfPresentedViewInContainerView : CGRect {
        guard let containerView = containerView else { return CGRect() }
        
        return CGRect(x: context.contentInset.left, y: containerView.bounds.height - context.contentInset.top - context.presentedContentSize.height - context.contentInset.bottom, width: containerView.bounds.width - context.contentInset.left - context.contentInset.right, height: context.presentedContentSize.height)
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let width = parentSize.width
        let height = context.presentedContentSize.height
        return CGSize(width: width, height: height)
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
