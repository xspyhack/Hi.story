//
//  DraftCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 11/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class DraftCell: UITableViewCell, Reusable {
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.title
        label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        return label
    }()
    
    fileprivate var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.body
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate var updatedAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.description
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow - 1, for: .vertical)
        contentLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow - 1, for: .vertical)
        
        contentView.addSubview(updatedAtLabel)
        updatedAtLabel.translatesAutoresizingMaskIntoConstraints = false
        updatedAtLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
        let views: [String: Any] = [
            "titleLabel": titleLabel,
            "contentLabel": contentLabel,
            "updatedAtLabel": updatedAtLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-16-|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[titleLabel]-12-[contentLabel]-(>=12)-[updatedAtLabel]-14-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
}

extension DraftCell: Configurable {
    
    func configure(withPresenter presenter: DraftCellModelType) {
        titleLabel.text = presenter.title
        contentLabel.text = presenter.content
        updatedAtLabel.text = Date(timeIntervalSince1970: presenter.updatedAt).hi.yearMonthDay
    }
}
