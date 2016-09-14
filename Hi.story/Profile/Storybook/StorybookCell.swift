//
//  StorybookCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/16/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import Kingfisher

class StorybookCell: UICollectionViewCell, Reusable {
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "album")
        return imageView
    }()
    
    fileprivate lazy var overlayView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return view
    }()
    
    fileprivate lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Storybook"
        label.textColor = UIColor.white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
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
        
        let imageViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        let imageViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views)
        
        let overlayViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", options: [], metrics: nil, views: views)
        let overlayViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: [], metrics: nil, views: views)
        
        let textLabelConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[textLabel]|", options: [], metrics: nil, views: views)
        let textLabelCenterY = NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(imageViewConstraintsH)
        NSLayoutConstraint.activate(imageViewConstraintsV)
        
        NSLayoutConstraint.activate(overlayViewConstraintsH)
        NSLayoutConstraint.activate(overlayViewConstraintsV)
        
        NSLayoutConstraint.activate(textLabelConstraintsH)
        NSLayoutConstraint.activate([textLabelCenterY])
    }
}

extension StorybookCell: Configurable {
    
    func configure(withPresenter presenter: StorybookCellModelType) {
        textLabel.text = presenter.name
        imageView.kf_setImageWithURL(presenter.coverImageURL)
    }
}
