//
//  CollectionCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import Kingfisher

typealias CollectionPresentable = TextPresentable & DescriptionPresentable & ImagePresentable

class CollectionCell: UICollectionViewCell, NibReusable {

    @IBOutlet fileprivate weak var overlayView: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let featuredHeight: CGFloat = Constant.featuredHeight
        let standardHeight: CGFloat = Constant.standardHegiht
        
        let delta = 1 - (featuredHeight - frame.height) / (featuredHeight - standardHeight)
        
        let minAlpha: CGFloat = Constant.minAlpha
        let maxAlpha: CGFloat = Constant.maxAlpha
        
        let alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        overlayView.alpha = alpha
        
        let scale = max(delta, 0.5)
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        descriptionLabel.alpha = delta
    }
    
    /*
    func configure(withPresenter presenter: CollectionPresentable) {
        presenter.updateTextLabel(titleLabel)
        presenter.updateDescriptionLabel(descriptionLabel)
        presenter.updateImageView(imageView)
    }
    */
}

extension CollectionCell: Configurable {
    
    func configure(withPresenter presenter: CollectionCellModelType) {
        titleLabel.text = presenter.title
        descriptionLabel.text = presenter.description
        imageView.hi.setImage(with: presenter.coverImageURL)
    }
}

extension CollectionCell {
    
    struct Constant {
        static let featuredHeight: CGFloat = 280
        static let standardHegiht: CGFloat = 100
        
        static let minAlpha: CGFloat = 0.3
        static let maxAlpha: CGFloat = 0.75
    }
}
