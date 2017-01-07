//
//  SwitchCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 23/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class SwitchCell: UITableViewCell, Reusable {
    
    var toggleSwitchStateChangedAction: ((_ on: Bool) -> Void)?
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.title
        label.text = "Title"
        return label
    }()
    
    private(set) lazy var toggleSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(SwitchCell.toggleSwitchStateChanged(_:)), for: .valueChanged)
        s.onTintColor = UIColor.hi.tint
        return s
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func toggleSwitchStateChanged(_ sender: UISwitch) {
        
        toggleSwitchStateChangedAction?(sender.isOn)
    }
    
    fileprivate func setup() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "titleLable": titleLabel,
            "toggleSwitch": toggleSwitch,
        ] as [String : Any]
        
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLable]-[toggleSwitch]-20-|", options: [.alignAllCenterY], metrics: nil, views: views)
        
        let centerY = titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        
        NSLayoutConstraint.activate(constraintsH)
        NSLayoutConstraint.activate([centerY])
    }
}
