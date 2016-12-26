//
//  HistoryHeaderView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 20/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol HistoryHeaderViewModelType {
    var createdAt: TimeInterval { get }
    var color: UIColor { get }
}

struct HistoryHeaderViewModel: HistoryHeaderViewModelType {
    
    let createdAt: TimeInterval
    let color: UIColor
}

class HistoryHeaderView: UICollectionReusableView, Reusable {
    
    fileprivate lazy var agoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        label.text = "1 YEAR AGO"
        return label
    }()
    
    fileprivate lazy var weekdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "SUN"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        addSubview(agoLabel)
        agoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(weekdayLabel)
        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let agoLabelCenterY = agoLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        let agoLabelCenterX = agoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        
        let weekdayLabelCenterY = weekdayLabel.centerYAnchor.constraint(equalTo: agoLabel.centerYAnchor)
        let weekdayLabelLeading = weekdayLabel.leadingAnchor.constraint(equalTo: agoLabel.trailingAnchor, constant: 8.0)
        
        NSLayoutConstraint.activate([agoLabelCenterX, agoLabelCenterY, weekdayLabelCenterY, weekdayLabelLeading])
    }
}

extension HistoryHeaderView: Configurable {
    
    func configure(withPresenter presenter: HistoryHeaderViewModelType) {
        
        // calc
        // background color
    }
}
