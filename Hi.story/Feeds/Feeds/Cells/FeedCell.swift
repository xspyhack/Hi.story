//
//  FeedCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 23/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol FeedCellModelType {
    var title: String { get }
    var body: String { get }
    var imageURL: String? { get }
}

struct FeedCellModel: FeedCellModelType {
    
    let title: String
    let body: String
    let imageURL: String?
    
    init(story: Story) {
        self.title = story.title
        self.body = story.body
        self.imageURL = nil
    }
}

class FeedCell: UICollectionViewCell, Reusable {
    
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
        label.numberOfLines = 0
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
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "titleLabel": titleLabel,
            "bodyLabel": bodyLabel,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLabel]-20-|", options: [], metrics: nil, views: views)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-24-[titleLabel]-16-[bodyLabel]-24-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
}

extension FeedCell: Configurable {
    
    func configure(withPresenter presenter: FeedCellModelType) {
        //
    }
}
