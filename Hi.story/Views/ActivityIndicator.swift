//
//  ActivityIndicator.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/30/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

class ActivityIndicator {
    
    static let sharedInstance = ActivityIndicator()
    
    private init() {
    }
    
    var dismissAfter: NSTimer?
    private var isShowing = false
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .White)
        return view
    }()
    
    func show(blockingUI: Bool = true) {
        if self.isShowing {
            return
        }
        
        DispatchQueue.async { 

            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate, window = delegate.window {
                self.isShowing = true
                self.containerView.userInteractionEnabled = blockingUI
                self.containerView.alpha = 0.0
                window.addSubview(self.containerView)
                self.containerView.frame = window.bounds
                
                UIView.animateWithDuration(0.2, animations: {
                    self.containerView.alpha = 1.0
                    }, completion: { (finished) in
                        self.containerView.addSubview(self.activityIndicator)
                        self.activityIndicator.center = self.containerView.center
                        self.activityIndicator.startAnimating()
                        
                        self.activityIndicator.alpha = 0.0
                        self.activityIndicator.transform = CGAffineTransformMakeScale(0.001, 0.001)
                        
                        UIView.animateWithDuration(0.2, animations: {
                            self.activityIndicator.transform = CGAffineTransformMakeScale(1.0, 1.0)
                            self.activityIndicator.alpha = 1.0
                            }, completion: { (finished) in
                                self.activityIndicator.transform = CGAffineTransformIdentity
                                
                                if let dismissAfter = self.dismissAfter {
                                    dismissAfter.invalidate()
                                }
                                
                                self.dismissAfter = NSTimer.scheduledTimerWithTimeInterval(Defaults.forcedHideActivityIndicatorTimeInterval, target: self, selector: #selector(self.forcedHide), userInfo: nil, repeats: false)
                        })
                })
                
            }
        }
    }
    
    func hide(completion: (() -> Void)? = nil) {
        
        DispatchQueue.async {
            
            if self.isShowing {
                self.activityIndicator.transform = CGAffineTransformIdentity
                
                UIView.animateWithDuration(0.2, animations: {
                    self.activityIndicator.transform = CGAffineTransformMakeScale(0.001, 0.001)
                    self.activityIndicator.alpha = 0.0
                    }, completion: { (finished) in
                        self.activityIndicator.removeFromSuperview()
                        
                        UIView.animateWithDuration(0.1, animations: {
                            self.containerView.alpha = 0.0
                            }, completion: { (finished) in
                                self.containerView.removeFromSuperview()
                                completion?()
                        })
                })
            }
        }
    }
    
    @objc private func forcedHide() {
        hide()
    }
}