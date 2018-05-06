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
        label.textAlignment = .center
        label.numberOfLines = 0
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
    
    private func setup() {
        
        view.addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "tipsLabel": tipsLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[tipsLabel]-16-|", options: [], metrics: nil, views: views)
        
        let centerY = NSLayoutConstraint(item: tipsLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate([centerY])
    }
}
