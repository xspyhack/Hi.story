//
//  BaseViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 7/24/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // MARK: Rx
    
    let disposeBag = DisposeBag()

    private(set) var isViewDidAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isViewDidAppear {
            isViewDidAppear = true
            firstViewDidAppear(animated)
        }
    }

    func firstViewDidAppear(_ animated: Bool) {
        // override in subclass
    }
}
