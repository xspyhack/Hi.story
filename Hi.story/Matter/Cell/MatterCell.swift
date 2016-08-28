//
//  MatterCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

class MatterCell: UITableViewCell, Reusable {

    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(32.0, weight: UIFontWeightMedium)
        label.text = "+333"
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        
        contentView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel?.text = "Matter"
        
        let views = [
            "daysLabel": daysLabel,
        ]
        
        let H = NSLayoutConstraint.constraintsWithVisualFormat("H:[daysLabel]-16-|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint(item: daysLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activateConstraints(H)
        NSLayoutConstraint.activateConstraints([V])
    }
    
    override var layoutMargins: UIEdgeInsets {
        get {
            return UIEdgeInsetsZero
        }
        set {}
    }
}

extension MatterCell: Configurable {
    
    func configure(withPresenter presenter: MatterCellModelType) {
        textLabel?.text = presenter.title
        daysLabel.text = "\(presenter.days)"
        daysLabel.textColor = UIColor(hex: presenter.tag)
    }
}
