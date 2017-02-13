//
//  StoryCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 12/02/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol StoryCellModelType {
    var title: String { get }
    var body: String { get }
    var imageURL: String? { get }
}

struct StoryCellCellModel: StoryCellModelType {
    
    let title: String
    let body: String
    let imageURL: String?
    
    init(story: Story) {
        self.title = story.title
        self.body = story.body
        self.imageURL = nil
    }
}

final class StoryCell: UITableViewCell, Reusable {
    
    static let margin: CGFloat = 16.0
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "四月是你的谎言"
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "飞机穿梭于茫茫星海中逐渐远去，你如猫般，无声靠近，从意想不到的角度玩弄他人，而我只能呆愣在原地，永远只能跟随你的步伐。"
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 4
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
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "titleLabel": titleLabel,
            "bodyLabel": bodyLabel,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[titleLabel]-(margin)-|", options: [], metrics: ["margin": StoryImageCell.margin], views: views)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[titleLabel]-16-[bodyLabel]-32-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
    
    static func height(with story: Story, width: CGFloat) -> CGFloat {
        
        let titleHeight = story.title.hi.height(with: width - StoryCell.margin * 2, fontSize: 24.0)
        let contentHeight = story.body.hi.height(with: width - StoryCell.margin * 2, fontSize: 14.0)
        
        let height = titleHeight + 16.0 + min(contentHeight, Defaults.storiesMaxContentHeight) + 32.0
        
        if story.attachment != nil {
            return 16.0 + height + width * 9.0 / 16.0
        } else {
            return 12.0 + height
        }
    }
}

extension StoryCell: Configurable {
    
    func configure(withPresenter presenter: StoryCellModelType) {
        titleLabel.text = presenter.title
        bodyLabel.text = presenter.body
    }
}
