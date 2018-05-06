//
//  SelectableCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class SelectableCell: UITableViewCell, Reusable {

    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "checkmark_normal")
        return imageView
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.lightText
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hi.text
        label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.bold)
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
        
        selectionStyle = .none
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(checkmarkImageView)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "nameLabel": nameLabel,
            "countLabel": countLabel,
            "checkmarkImageView": checkmarkImageView,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[nameLabel]-(>=12)-[countLabel]-12-[checkmarkImageView]-16-|", options: [.alignAllCenterY], metrics: nil, views: views)
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        NSLayoutConstraint.activate(h)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        if selected {
            nameLabel.textColor = UIColor.hi.tint
            checkmarkImageView.image = UIImage(named: "checkmark_selected")
        } else {
            nameLabel.textColor = UIColor.hi.text
            checkmarkImageView.image = UIImage(named: "checkmark_normal")
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            backgroundColor = UIColor(hex: "#F8F8F8")
        } else {
            backgroundColor = UIColor.white
        }
    }
    
    func configure(text: String, detail: String? = nil) {
        nameLabel.text = text
        countLabel.text = detail
    }
}

