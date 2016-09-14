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
    
    fileprivate lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        preferredContentSize = CGSize(width: 200, height: 100)
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setup() {
        
        view.addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "tipsLabel": tipsLabel,
        ]
        
        let H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tipsLabel]-|", options: [], metrics: nil, views: views)
        
        let centerY = NSLayoutConstraint(item: tipsLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(H)
        NSLayoutConstraint.activate([centerY])
    }
}
