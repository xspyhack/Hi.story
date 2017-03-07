//
//  FeedItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol FeedItemCellModelType {
    var title: String { get }
    var body: String { get }
    var imageURL: String? { get }
    var createdAt: String { get }
}

struct FeedItemCellModel: FeedItemCellModelType {
    
    let title: String
    let body: String
    let imageURL: String?
    let createdAt: String
    
    init(story: Story) {
        self.title = story.title
        self.body = story.body
        self.imageURL = nil
        self.createdAt = Date(timeIntervalSince1970: story.createdAt).hi.time
    }
}

class FeedItemCell: HistoryItemCell, Reusable {
 
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Feed Item"
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.numberOfLines = 1
        label.textColor = UIColor.hi.title
        return label
    }()
    
    fileprivate lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "飞机穿梭于茫茫星海中逐渐远去，你如猫般，无声靠近，从意想不到的角度玩弄他人，而我只能呆愣在原地，永远只能跟随你的步伐。"
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.hi.body
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
    
    private func setup() {
        
        iconImageView.image = UIImage.hi.feedIcon
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "titleLabel": titleLabel,
            "bodyLabel": bodyLabel,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel]-(padding)-|", options: [], metrics: ["padding": FeedItemCell.iconPadding], views: views)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[titleLabel]-16-[bodyLabel]-32-|", options: [.alignAllLeading, .alignAllTrailing], metrics: ["margin": FeedItemCell.iconContainerHeight], views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
    
    static func height(with feed: Feed, width: CGFloat) -> CGFloat {
        
        guard let story = feed.story else { return 0.0 }
        
        let titleHeight = story.title.hi.height(with: width - FeedItemCell.iconPadding * 2, fontSize: 24.0)
        let contentHeight = story.body.hi.height(with: width - FeedItemCell.iconPadding * 2, fontSize: 14.0)
        
        let height = titleHeight + 16.0 + min(contentHeight, Defaults.feedsMaxContentHeight) + 32.0
        
        if story.attachment != nil {
            return FeedItemCell.iconContainerHeight + height + width * 9.0 / 16.0 + 16.0
        } else {
            return FeedItemCell.iconContainerHeight + height
        }
    }
}

extension FeedItemCell: Configurable {
    
    func configure(withPresenter presenter: FeedItemCellModelType) {
        titleLabel.text = presenter.title
        bodyLabel.text = presenter.body
        createdAtLabel.text = presenter.createdAt
    }
}
