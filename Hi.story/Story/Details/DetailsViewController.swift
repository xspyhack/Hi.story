//
//  DetailsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 25/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class DetailsViewController: BaseViewController {
    
    var showsLocationAction: ((LocationInfo) -> Void)?
    
    var viewModel: DetailsViewModel?

    @IBOutlet weak var createdLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var charsCountLabel: UILabel!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationAccessoryImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel else { return }
        
        wordsCountLabel.text = String(viewModel.words)
        charsCountLabel.text = String(viewModel.chars)
        
        updatedLabel.text = viewModel.updated
        createdLabel.text = viewModel.created
        
        locationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if let location = viewModel.location {
                    self?.showsLocationAction?(location)
                }
            })
            .disposed(by: disposeBag)
        
        if let address = viewModel.address {
            locationButton.isHidden = false
            locationAccessoryImageView.isHidden = false
            locationButton.setTitle(address, for: .normal)
        } else {
            locationButton.isHidden = true
            locationAccessoryImageView.isHidden = true
            createdLabelBottomConstraint.constant = 24.0
        }
    }
}

