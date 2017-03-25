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
   
    var deleteAction: (() -> Void)?
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "album")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6.0
        return imageView
    }()
    
    fileprivate lazy var overlayView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.layer.cornerRadius = 6.0
        return view
    }()
    
    fileprivate lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Storybook"
        label.font = UIFont(name: "Didot-Bold", size: 20.0)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    fileprivate lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.hi.storybookDelete, for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.isHidden = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    fileprivate func setup() {
        
        layer.shadowRadius = 12.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 1.0
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "imageView": imageView,
            "overlayView": overlayView,
            "textLabel": textLabel,
            "countLabel": countLabel,
            "deleteButton": deleteButton,
        ]
        
        let imageViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        let imageViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views)
        
        let overlayViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", options: [], metrics: nil, views: views)
        let overlayViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: [], metrics: nil, views: views)
        
        let textLabelConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[textLabel]-4-|", options: [], metrics: nil, views: views)
        let textLabelCenterY = NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(imageViewConstraintsH)
        NSLayoutConstraint.activate(imageViewConstraintsV)
        
        NSLayoutConstraint.activate(overlayViewConstraintsH)
        NSLayoutConstraint.activate(overlayViewConstraintsV)
        
        NSLayoutConstraint.activate(textLabelConstraintsH)
        NSLayoutConstraint.activate([textLabelCenterY])
        
        countLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8.0).isActive = true
        countLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8.0).isActive = true
        
        deleteButton.centerXAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 2.0).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: imageView.topAnchor, constant: 2.0).isActive = true
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        deleteAction?()
    }
    
    var isEditing: Bool = false {
        didSet {
            deleteButton.isHidden = !isEditing
            
            if isEditing {
                transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            } else {
                transform = CGAffineTransform.identity
            }
        }
    }
}

extension StorybookCell: Configurable {
    
    func configure(withPresenter presenter: StorybookCellModelType) {
        textLabel.text = presenter.name.uppercased()
        countLabel.text = "\(presenter.count)"
        imageView.setImage(with: presenter.coverImageURL, placeholder: UIImage.hi.storybook)
    }
}
