//
//  AboutCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class AboutCell: UITableViewCell, Reusable {

    lazy var annotationLabel: UILabel = {
        let label = UILabel()
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
        
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(annotationLabel)
        annotationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        annotationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 16).isActive = true
        annotationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

}
