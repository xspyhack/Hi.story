//
//  ThemeCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 25/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class ThemeCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowRadius = 16.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 1.0
        
        imageView.layer.cornerRadius = 10.0
        imageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}
