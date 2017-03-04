//
//  FeedItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

class FeedItemCell: HistoryItemCell, Reusable {
 
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Feed Item"
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.numberOfLines = 1
        label.textColor = UIColor.hi.title
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        iconImageView.image = UIImage.hi.feedIcon
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}
