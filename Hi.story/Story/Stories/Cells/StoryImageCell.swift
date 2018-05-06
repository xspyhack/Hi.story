//
//  StoryImageCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 12/02/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

struct StoryImageCellModel: StoryCellModelType {
    
    let title: String
    let body: String
    let imageURL: String?
    
    init(story: Story) {
        self.title = story.title
        self.body = story.body
        self.imageURL = story.attachment?.urlString
    }
}

final class StoryImageCell: UITableViewCell, Reusable {
    
    static let margin: CGFloat = 16.0
    
    private lazy var storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "四月是你的谎言"
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
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
        
        contentView.addSubview(storyImageView)
        storyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "storyImageView": storyImageView,
            "titleLabel": titleLabel,
            "bodyLabel": bodyLabel,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[titleLabel]-(margin)-|", options: [], metrics: ["margin": StoryImageCell.margin], views: views)
        
        let imageViewHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[storyImageView]|", options: [], metrics: nil, views: views)
        
        let imageViewVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[storyImageView]-16-[titleLabel]", options: [], metrics: nil, views: views)
        let imageViewHeightConstraint = NSLayoutConstraint(item: storyImageView, attribute: .height, relatedBy: .equal, toItem: storyImageView, attribute: .width, multiplier: 9.0 / 16.0, constant: 0.0)
        
        NSLayoutConstraint.activate(imageViewHConstraints)
        NSLayoutConstraint.activate(imageViewVConstraints)
        NSLayoutConstraint.activate([imageViewHeightConstraint])
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLabel]-16-[bodyLabel]-48-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
}

extension StoryImageCell: Configurable {
    
    func configure(withPresenter presenter: StoryCellModelType) {
        titleLabel.text = presenter.title
        bodyLabel.text = presenter.body
        storyImageView.hi.setImage(with: presenter.imageURL.flatMap { URL(string: $0) })
    }
}
