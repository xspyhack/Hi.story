//
//  TextCard.swift
//  Himemory
//
//  Created by bl4ckra1sond3tre on 05/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit

class TextCard: Card {
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate(textLabel.hi.edges(with: UIEdgeInsets(all: 20)))
    }
}

extension TextCard {
    
    func configure(withText text: String) {
        textLabel.text = text
    }
}
