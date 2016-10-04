//
//  MatterViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

final class MatterViewController: BaseViewController {
    
    @IBOutlet private weak var notesTextView: UITextView! {
        didSet {
            notesTextView.textContainerInset = UIEdgeInsets(top: 12.0, left: 8.0, bottom: 12.0, right: 8.0)
        }
    }
    @IBOutlet private weak var whenLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var viewModel: MatterViewModel?
    
    static let identifier = "MatterViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Matter"
        
        guard let viewModel = viewModel else { return }
        
        viewModel.title
            .drive(titleLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.when
            .drive(whenLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.notes
            .drive(notesTextView.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.tag
            .drive(onNext: { [weak self] textColor in
                self?.titleLabel.textColor = textColor
                self?.whenLabel.textColor = textColor
            })
            .addDisposableTo(disposeBag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
