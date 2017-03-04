//
//  MatterItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 30/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class MatterItemCell: HistoryItemCell, Reusable {

    private static let titleFont = UIFont.systemFont(ofSize: 24.0)
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Matter"
        label.font = MatterItemCell.titleFont
        label.numberOfLines = 1
        label.textColor = UIColor.hi.title
        return label
    }()
    
    fileprivate lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.text = "飞机穿梭于茫茫星海中逐渐远去，你如猫般，无声靠近，从意想不到的角度玩弄他人，而我只能呆愣在原地，永远只能跟随你的步伐。"
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 4
        label.textColor = UIColor.hi.body
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
        
        iconImageView.image = UIImage.hi.matterIcon
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
       
        contentView.addSubview(notesLabel)
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        
        let views: [String: Any] = [
            "titleLabel": titleLabel,
            "notesLabel": notesLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel]-(padding)-|", options: [], metrics: ["padding": MatterItemCell.iconPadding], views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[titleLabel]-16-[notesLabel]", options: [.alignAllLeading, .alignAllTrailing], metrics: ["margin": MatterItemCell.iconContainerHeight], views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
    
    override var layoutMargins: UIEdgeInsets {
        get {
            return UIEdgeInsets.zero
        }
        set {}
    }
    
    static func height(with viewModel: MatterCellModelType, width: CGFloat) -> CGFloat {
        let titleHeight = titleFont.lineHeight.rounded(.up)
        if viewModel.notes.isEmpty {
            return MatterItemCell.iconContainerHeight + titleHeight
        } else {
            return MatterItemCell.iconContainerHeight + viewModel.notes.hi.height(with: width - 2 * MatterItemCell.iconPadding, fontSize: 14.0) + 16.0 + titleHeight
        }
    }
}

extension MatterItemCell: Configurable {
    
    func configure(withPresenter presenter: MatterCellModelType) {
        createdAtLabel.text = Date(timeIntervalSince1970: presenter.createdAt).hi.time
        titleLabel.text = presenter.title
        notesLabel.text = presenter.notes
    }
}
