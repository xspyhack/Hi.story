//
//  DescriptionPresentable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol DescriptionPresentable {
    var description: String { get }
    var descriptionTextColor: UIColor { get }
    var descriptionFont: UIFont { get }
    
    func updateDescriptionLabel(_ label: UILabel)
}

extension DescriptionPresentable {
    var descriptionTextColor: UIColor { return UIColor.white }
    var descriptionFont: UIFont { return .systemFont(ofSize: 14.0) }
    
    func updateDescriptionLabel(_ label: UILabel) {
        label.text = description
        label.textColor = descriptionTextColor
        label.font = descriptionFont
    }
}
