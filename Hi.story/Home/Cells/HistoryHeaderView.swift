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
        label.font = UIFont.systemFont(ofSize: 12.0)
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
        let year = Date(timeIntervalSince1970: presenter.createdAt).hi.year
        if let years = Int(year), let thisYears = Int(Date().hi.year) {
            let ago = thisYears - years
            agoLabel.text = (ago == 0) ? "THIS YEAR" : (ago == 1 ? "1 YEAR AGO" : "\(thisYears - years) YEARS AGO")
        }
        
        let weak = Date(timeIntervalSince1970: presenter.createdAt).hi.weekdayIndex
        
        switch weak {
        case 0:
            weekdayLabel.text = "SUN"
        case 1:
            weekdayLabel.text = "MON"
        case 2:
            weekdayLabel.text = "TUE"
        case 3:
            weekdayLabel.text = "WED"
        case 4:
            weekdayLabel.text = "THU"
        case 5:
            weekdayLabel.text = "FRI"
        case 6:
            weekdayLabel.text = "SAT"
        default:
            weekdayLabel.text = "NON"
        }
        
        // background color
        backgroundColor = presenter.color
    }
}
