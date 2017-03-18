//
//  DraftImageCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 19/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class DraftImageCell: UITableViewCell, Reusable {
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.title
        label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        return label
    }()
    
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.body
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var updatedAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.description
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()
    
    fileprivate lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var bodyView = UIView()
    
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
        
        contentView.addSubview(bodyView)
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.setContentHuggingPriority(UILayoutPriorityDefaultLow - 1, for: .vertical)
        bodyView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow - 1, for: .vertical)
        
        bodyView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyView.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        bodyView.addSubview(updatedAtLabel)
        updatedAtLabel.translatesAutoresizingMaskIntoConstraints = false
        updatedAtLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
        
        let views: [String: Any] = [
            "bodyView": bodyView,
            "titleLabel": titleLabel,
            "contentLabel": contentLabel,
            "updatedAtLabel": updatedAtLabel,
            "thumbnailImageView": thumbnailImageView,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-16-|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[titleLabel]-12-[bodyView(>=87)]-14-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
        
        let bodyViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentLabel]-16-[thumbnailImageView(87)]|", options: [.alignAllTop], metrics: nil, views: views)
        let bodyViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentLabel]-(>=12)-[updatedAtLabel]|", options: [.alignAllLeading], metrics: nil, views: views)
        NSLayoutConstraint.activate(bodyViewH)
        NSLayoutConstraint.activate(bodyViewV)
        thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 1.0).isActive = true
    }
}

extension DraftImageCell: Configurable {
    
    func configure(withPresenter presenter: DraftCellModelType) {
        titleLabel.text = presenter.title
        contentLabel.text = presenter.content
        updatedAtLabel.text = Date(timeIntervalSince1970: presenter.updatedAt).hi.yearMonthDay
        thumbnailImageView.image = presenter.thumbnail
    }
}
