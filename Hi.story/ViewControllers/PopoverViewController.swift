//
//  PopoverViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {
    
    var tips: String? {
        didSet {
            tipsLabel.text = tips
        }
    }
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        preferredContentSize = CGSize(width: 200, height: 100)
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        
        view.addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "tipsLabel": tipsLabel,
        ]
        
        let H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tipsLabel]-|", options: [], metrics: nil, views: views)
        
        let centerY = NSLayoutConstraint(item: tipsLabel, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activateConstraints(H)
        NSLayoutConstraint.activateConstraints([centerY])
    }
}
