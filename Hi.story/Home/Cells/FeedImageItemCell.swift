//
//  FeedImageItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 06/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

struct FeedImageItemCellModel: FeedItemCellModelType {
    
    let title: String
    let body: String
    let imageURL: String?
    let createdAt: String
    
    init(story: Story) {
        self.title = story.title
        self.body = story.body
        self.imageURL = story.attachment?.urlString
        self.createdAt = Date(timeIntervalSince1970: story.createdAt).hi.time
    }
}

class FeedImageItemCell: HistoryItemCell, Reusable {
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
   
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
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "imageView": imageView,
            "titleLabel": titleLabel,
            "bodyLabel": bodyLabel,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel]-(padding)-|", options: [], metrics: ["padding": FeedImageCell.margin], views: views)
        
        let imageViewHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        
        let imageViewVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[imageView]-16-[titleLabel]", options: [], metrics: ["margin": FeedImageItemCell.iconContainerHeight], views: views)
        let imageViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 9.0 / 16.0, constant: 0.0)
        
        NSLayoutConstraint.activate(imageViewHConstraints)
        NSLayoutConstraint.activate(imageViewVConstraints)
        NSLayoutConstraint.activate([imageViewHeightConstraint])
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLabel]-16-[bodyLabel]-32-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
    
    static func height(with feed: Feed, width: CGFloat) -> CGFloat {
        
        guard let story = feed.story else { return 0.0 }
        
        let titleHeight = story.title.hi.height(with: width - FeedImageItemCell.iconPadding * 2, fontSize: 24.0)
        let contentHeight = story.body.hi.height(with: width - FeedImageItemCell.iconPadding * 2, fontSize: 14.0)
        
        let height = titleHeight + 16.0 + min(contentHeight, Defaults.feedsMaxContentHeight) + 32.0
        
        if story.attachment != nil {
            return FeedImageItemCell.iconContainerHeight + height + width * 9.0 / 16.0
        } else {
            return FeedImageItemCell.iconContainerHeight + height
        }
    }
}

extension FeedImageItemCell: Configurable {
    
    func configure(withPresenter presenter: FeedItemCellModelType) {
        titleLabel.text = presenter.title
        bodyLabel.text = presenter.body
        imageView.setImage(with: presenter.imageURL.flatMap { URL(string: $0) })
        createdAtLabel.text = presenter.createdAt
    }
}
