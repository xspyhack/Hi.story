//
//  MatterViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MatterViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    var viewModel: MatterViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.xh_registerReusableCell(MatterCell)
        
        tableView.rx_itemSelected
            .subscribeNext { [weak self] indexPath in }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MatterViewController {
    
}
