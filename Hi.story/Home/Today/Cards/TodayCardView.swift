//
//  TodayCardView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 04/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class TodayCardView: UIView {
    
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
    
    private func setup() {
        backgroundColor = UIColor.clear
        layer.shadowRadius = 12.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 1.0
    }
}
