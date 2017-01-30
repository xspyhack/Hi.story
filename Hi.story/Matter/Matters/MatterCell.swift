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
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = "Matter"
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
        
        //selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        
        let views = [
            "titleLabel": titleLabel,
            "daysLabel": daysLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-(>=8)-[daysLabel]-16-|", options: [.alignAllCenterY], metrics: nil, views: views)
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        NSLayoutConstraint.activate(h)
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
        titleLabel.text = presenter.title
        daysLabel.text = (presenter.days > 0) ? "+\(presenter.days)" : "\(presenter.days)"
        daysLabel.textColor = UIColor(hex: presenter.tag)
    }
}
