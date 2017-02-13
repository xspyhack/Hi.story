//
//  TodayViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/10/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class TodayViewController: UIViewController {
   
    fileprivate struct Constant {
        static let gap: CGFloat = 24.0
        static let padding: CGFloat = 32.0
        static let numberOfRow = 2
        static let ratio: CGFloat = 6 / 9
        static let matterRowHeight: CGFloat = 64.0
        static let avatarSize = CGSize(width: 120.0, height: 120.0)
        static let bottomToolbarHeight: CGFloat = 44.0
    }
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.brown
        
        title = "Today"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
