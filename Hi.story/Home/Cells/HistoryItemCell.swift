//
//  HistoryItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class HistoryItemCell: UICollectionViewCell {
   
    private(set) var iconSize: CGSize = CGSize(width: 16, height: 16)
    
    static let iconContainerHeight: CGFloat = 32.0
    static let iconPadding: CGFloat = 16.0
    
    private(set) lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.hi.connectorIcon
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private(set) lazy var createdAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.description
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()
    
    private(set) lazy var iconView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.addSubview(createdAtLabel)
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["iconImageView": iconImageView, "iconView": iconView, "createdAtLabel": createdAtLabel]
        
        let iconH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[iconView]|", options: [], metrics: nil, views: views)
        let iconV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[iconView(height)]", options: [], metrics: ["height": HistoryItemCell.iconContainerHeight], views: views)
        
        NSLayoutConstraint.activate(iconH)
        NSLayoutConstraint.activate(iconV)
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[iconImageView(16)]-8-[createdAtLabel]", options: [.alignAllCenterY], metrics: ["padding": HistoryItemCell.iconPadding], views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:[iconImageView(16)]", options: [], metrics: nil, views: views)
        iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
}
