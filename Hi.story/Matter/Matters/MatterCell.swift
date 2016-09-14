//
//  MatterCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class MatterCell: UITableViewCell, Reusable {

    fileprivate lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32.0, weight: UIFontWeightMedium)
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

    fileprivate func setup() {
        
        contentView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel?.text = "Matter"
        
        let views = [
            "daysLabel": daysLabel,
        ]
        
        let H = NSLayoutConstraint.constraints(withVisualFormat: "H:[daysLabel]-16-|", options: [], metrics: nil, views: views)
        let V = NSLayoutConstraint(item: daysLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(H)
        NSLayoutConstraint.activate([V])
    }
    
    override var layoutMargins: UIEdgeInsets {
        get {
            return UIEdgeInsets.zero
        }
        set {}
    }
}

extension MatterCell: Configurable {
    
    func configure(withPresenter presenter: MatterCellModelType) {
        textLabel?.text = presenter.title
        daysLabel.text = (presenter.days > 0) ? "+\(presenter.days)" : "\(presenter.days)"
        daysLabel.textColor = UIColor(hex: presenter.tag)
    }
}
