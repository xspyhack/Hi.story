//
//  FeedSectionHeaderView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 23/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol FeedSectionHeaderViewModelType {
    
    var avatar: String { get }
    var nickname: String { get }
}

struct FeedSectionHeaderViewModel: FeedSectionHeaderViewModelType {
    
    var avatar: String
    var nickname: String
    
    init(user: User) {
        self.avatar = user.avatarURLString
        self.nickname = user.nickname
    }
}

class FeedSectionHeaderView: UICollectionReusableView, Reusable {
    
    fileprivate lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        return imageView
    }()
    
    fileprivate lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "__b233"
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    
    fileprivate lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("...", for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(nicknameLabel)
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "avatarImageView": avatarImageView,
            "nicknameLabel": nicknameLabel,
            "moreButton": moreButton,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[avatarImageView(40)]-16-[nicknameLabel]-(>=10)-[moreButton(44)]-20-|", options: [.alignAllCenterY], metrics: nil, views: views)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[avatarImageView(40)]", options: [], metrics: nil, views: views)
        
        let centerYConstraint = NSLayoutConstraint(item: avatarImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
        NSLayoutConstraint.activate([centerYConstraint])
    }
}

extension FeedSectionHeaderView: Configurable {
    
    func configure(withPresenter presenter: FeedSectionHeaderViewModelType) {
        
    }
}
