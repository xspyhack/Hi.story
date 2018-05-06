//
//  InputAccessoryView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 29/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit

public class InputAccessoryView: UIView {

    private var allLayoutConstraints = [NSLayoutConstraint]() {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
            NSLayoutConstraint.activate(allLayoutConstraints)
        }
    }
    
    deinit {
        allLayoutConstraints = []
    }
    
    public init(for view: UIView) {
        super.init(frame: .zero)
        
        addSubview(view)
        
        // Allow 'self' to be sized based on autolayout constraints. Without
        // this, the frame would have to be set manually.
        autoresizingMask = .flexibleHeight
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        defer {
            let leadingAnchor: NSLayoutXAxisAnchor
            let trailingAnchor: NSLayoutXAxisAnchor
            let topAnchor: NSLayoutYAxisAnchor
            let bottomAnchor: NSLayoutYAxisAnchor
            
            if #available(iOS 11, *) {
                leadingAnchor = safeAreaLayoutGuide.leadingAnchor
                trailingAnchor = safeAreaLayoutGuide.trailingAnchor
                topAnchor = safeAreaLayoutGuide.topAnchor
                bottomAnchor = safeAreaLayoutGuide.bottomAnchor
            } else {
                leadingAnchor = self.leadingAnchor
                trailingAnchor = self.trailingAnchor
                topAnchor = self.topAnchor
                bottomAnchor = self.bottomAnchor
            }
            
            allLayoutConstraints = [view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                    view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                    view.topAnchor.constraint(equalTo: topAnchor),
                                    view.bottomAnchor.constraint(equalTo: bottomAnchor)]
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        // Allow 'self' to be sized based on autolayout constraints. Without
        // this, the frame would have to be set manually.
        return .zero
    }
}
