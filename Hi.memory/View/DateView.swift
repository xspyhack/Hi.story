//
//  DateView.swift
//  Himemory
//
//  Created by bl4ckra1sond3tre on 06/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit

protocol DateViewModelType {
    var createdAt: TimeInterval { get }
    var color: UIColor { get }
}

struct DateViewModel: DateViewModelType {
    
    let createdAt: TimeInterval
    let color: UIColor
}

class DateView: UIView {
    
    private lazy var agoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "1 YEAR AGO"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var weekdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red.withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 9.0)
        label.text = "SUN"
        label.textAlignment = .center
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
        
        let stackView = UIStackView(arrangedSubviews: [agoLabel, weekdayLabel])
        stackView.axis = .vertical
        stackView.spacing = 0.0
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 3.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.0)
    }
}

extension DateView {
    
    func configure(withPresenter presenter: DateViewModelType) {
        
        // calc
        let year = Date(timeIntervalSince1970: presenter.createdAt).hi.year
        if let years = Int(year), let thisYears = Int(Date().hi.year) {
            let ago = thisYears - years
            if ago == 0 {
                agoLabel.text = "THIS YEAR"
            } else if ago == 1 {
                agoLabel.text = "1 YEAR AGO"
            } else if ago == -1 {
                agoLabel.text = "1 YEAR LATER"
            } else if ago > 0 {
                agoLabel.text = "\(ago) YEARS AGO"
            } else {
                agoLabel.text = "\(ago) YEARS LATER"
            }
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
        
        agoLabel.textColor = presenter.color
    }
}
