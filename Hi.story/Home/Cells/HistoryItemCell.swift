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
    private(set) var iconPadding: CGFloat = 16.0
    private(set) var iconContainerHeight: CGFloat = 48.0
    
    static let iconContainerHeight: CGFloat = 48.0
    
    private(set) lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.hi.connectorIcon
        imageView.contentMode = .scaleAspectFill
        return imageView
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
        
        let views: [String: Any] = ["iconImageView": iconImageView, "iconView": iconView]
        
        let iconH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[iconView]|", options: [], metrics: nil, views: views)
        let iconV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[iconView(48)]", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(iconH)
        NSLayoutConstraint.activate(iconV)
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[iconImageView(16)]", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[iconImageView(16)]", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
        
    }
}
