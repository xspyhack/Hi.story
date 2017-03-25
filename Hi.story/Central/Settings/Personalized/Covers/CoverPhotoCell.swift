//
//  CoverPhotoCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 16/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class CoverPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var maskedView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 20.0
        avatarImageView.clipsToBounds = true
        
        layer.shadowRadius = 16.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 1.0
        
        backgroundImageView.layer.cornerRadius = 6.0
        backgroundImageView.clipsToBounds = true
        maskedView.layer.cornerRadius = 6.0
    }
    
    override var isSelected: Bool {
        didSet {
            selectedImageView.isHidden = !isSelected
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}
