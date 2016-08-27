//
//  CardView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/23/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class CardView: UIView {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()
    
    private lazy var contentView: UIView = {
        return UIView()
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        configure()
    }
    
    private func configure() {
        
        addSubview(imageView)
        addSubview(contentView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "imageView": imageView,
            "contentView": contentView
        ]
        
        let hImageViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: views)
        let vImageViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: views)
        
        let hContentViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: [], metrics: nil, views: views)
        let vContentViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: [], metrics: nil, views: views)

        NSLayoutConstraint.activateConstraints(hImageViewConstraints)
        NSLayoutConstraint.activateConstraints(vImageViewConstraints)
        NSLayoutConstraint.activateConstraints(hContentViewConstraints)
        NSLayoutConstraint.activateConstraints(vContentViewConstraints)
    }

}
