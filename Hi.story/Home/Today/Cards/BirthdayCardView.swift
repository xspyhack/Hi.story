//
//  BirthdayCardView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class BirthdayCardView: UIView {
    
    private lazy var fireworks: Fireworks = Fireworks()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        print(bounds)
        setup()
    }
    
    func start() {
        fireworks.startAnimating()
    }
    
    func stop() {
        fireworks.stopAnimating()
    }
    
    private func setup() {
        
        addSubview(fireworks)
        fireworks.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "fireworks": fireworks
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[fireworks]|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[fireworks]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
}
