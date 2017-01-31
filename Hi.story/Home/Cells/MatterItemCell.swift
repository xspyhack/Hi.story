//
//  MatterItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 30/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class MatterItemCell: HisotryItemCell, Reusable {
 
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Matter"
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.numberOfLines = 1
        return label
    }()
    
    fileprivate lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.text = "飞机穿梭于茫茫星海中逐渐远去，你如猫般，无声靠近，从意想不到的角度玩弄他人，而我只能呆愣在原地，永远只能跟随你的步伐。"
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 4
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
       
        contentView.addSubview(notesLabel)
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "titleLabel": titleLabel,
            "notesLabel": notesLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-16-|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[titleLabel]-16-[notesLabel]-12-|", options: [.alignAllLeading, .alignAllLeading], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
    
    override var layoutMargins: UIEdgeInsets {
        get {
            return UIEdgeInsets.zero
        }
        set {}
    }
    
    static func height(with matter: Matter, width: CGFloat) -> CGFloat {
        return matter.body.hi.height(with: width, fontSize: 14.0) + 24 + 16 + 28.0
    }
}

extension MatterItemCell: Configurable {
    
    func configure(withPresenter presenter: MatterCellModelType) {
        titleLabel.text = presenter.title
        notesLabel.text = presenter.notes
    }
}
