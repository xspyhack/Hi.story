//
//  TextPresentable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol TextPresentable {
    var text: String { get }
    var textColor: UIColor { get }
    var font: UIFont { get }
    
    func updateTextLabel(label: UILabel)
}

extension TextPresentable {
    
    var font: UIFont { return .systemFontOfSize(36.0, weight: UIFontWeightMedium) }
    var textColor: UIColor { return .whiteColor() }
    
    func updateTextLabel(label: UILabel) {
        label.text = text
        label.textColor = textColor
        label.font = font
    }
}