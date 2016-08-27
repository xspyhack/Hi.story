//
//  CollectionCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Kingfisher

typealias CollectionPresentable = protocol<TextPresentable, DescriptionPresentable, ImagePresentable>

class CollectionCell: UICollectionViewCell, NibReusable {

    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let featuredHeight: CGFloat = Constant.featuredHeight
        let standardHeight: CGFloat = Constant.standardHegiht
        
        let delta = 1 - (featuredHeight - CGRectGetHeight(frame)) / (featuredHeight - standardHeight)
        
        let minAlpha: CGFloat = Constant.minAlpha
        let maxAlpha: CGFloat = Constant.maxAlpha
        
        let alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        overlayView.alpha = alpha
        
        let scale = max(delta, 0.5)
        titleLabel.transform = CGAffineTransformMakeScale(scale, scale)
        
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
        imageView.kf_setImage(withURL: presenter.coverImageURL)
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
