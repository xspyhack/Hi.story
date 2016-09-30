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
    
    static let shared = ActivityIndicator()
    
    private init() {
    }
    
    var dismissAfter: Timer?
    private var isShowing = false
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .white)
        return view
    }()
    
    func show(_ blockingUI: Bool = true) {
        if self.isShowing {
            return
        }
        
        DispatchQueue.main.async {

            if let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window {
                self.isShowing = true
                self.containerView.isUserInteractionEnabled = blockingUI
                self.containerView.alpha = 0.0
                window.addSubview(self.containerView)
                self.containerView.frame = window.bounds
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.containerView.alpha = 1.0
                }, completion: { (finished) in
                    self.containerView.addSubview(self.activityIndicator)
                    self.activityIndicator.center = self.containerView.center
                    self.activityIndicator.startAnimating()
                    
                    self.activityIndicator.alpha = 0.0
                    self.activityIndicator.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.activityIndicator.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.activityIndicator.alpha = 1.0
                    }, completion: { (finished) in
                        self.activityIndicator.transform = CGAffineTransform.identity
                    
                        if let dismissAfter = self.dismissAfter {
                            dismissAfter.invalidate()
                        }
                        
                        self.dismissAfter = Timer.scheduledTimer(timeInterval: Defaults.forcedHideActivityIndicatorTimeInterval, target: self, selector: #selector(self.forcedHide), userInfo: nil, repeats: false)
                    })
                })
                
            }
        }
    }
    
    func hide(_ completion: (() -> Void)? = nil) {
        
        DispatchQueue.main.async {
            
            if self.isShowing {
                self.activityIndicator.transform = CGAffineTransform.identity
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.activityIndicator.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    self.activityIndicator.alpha = 0.0
                }, completion: { (finished) in
                    self.activityIndicator.removeFromSuperview()
                    
                    UIView.animate(withDuration: 0.1, animations: {
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
