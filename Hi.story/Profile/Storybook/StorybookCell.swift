//
//  StorybookCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/16/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Kingfisher

class StorybookCell: UICollectionViewCell, Reusable {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.image = UIImage(named: "album")
        return imageView
    }()
    
    private lazy var overlayView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.text = "Storybook"
        label.textColor = UIColor.whiteColor()
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
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "imageView": imageView,
            "overlayView": overlayView,
            "textLabel": textLabel,
        ]
        
        let imageViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: views)
        let imageViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: views)
        
        let overlayViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[overlayView]|", options: [], metrics: nil, views: views)
        let overlayViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[overlayView]|", options: [], metrics: nil, views: views)
        
        let textLabelConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[textLabel]|", options: [], metrics: nil, views: views)
        let textLabelCenterY = NSLayoutConstraint(item: textLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activateConstraints(imageViewConstraintsH)
        NSLayoutConstraint.activateConstraints(imageViewConstraintsV)
        
        NSLayoutConstraint.activateConstraints(overlayViewConstraintsH)
        NSLayoutConstraint.activateConstraints(overlayViewConstraintsV)
        
        NSLayoutConstraint.activateConstraints(textLabelConstraintsH)
        NSLayoutConstraint.activateConstraints([textLabelCenterY])
    }
}

extension StorybookCell: Configurable {
    
    func configure(withPresenter presenter: StorybookCellModelType) {
        textLabel.text = presenter.name
        imageView.kf_setImageWithURL(presenter.coverImageURL)
    }
}
