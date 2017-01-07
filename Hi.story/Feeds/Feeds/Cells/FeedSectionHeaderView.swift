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
    
    var didSelect: ((Void) -> Void)?
    
    fileprivate lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(avatarTapped(_:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        button.contentMode = .scaleAspectFill
        return button
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
    
    struct Constant {
        static let margin: CGFloat = 16.0
        static let avatarSize = CGSize(width: 32.0, height: 32.0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        addSubview(avatarButton)
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(nicknameLabel)
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "avatarButton": avatarButton,
            "nicknameLabel": nicknameLabel,
            "moreButton": moreButton,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[avatarButton(40)]-12-[nicknameLabel]-(>=10)-[moreButton(44)]-(margin)-|", options: [.alignAllCenterY], metrics: ["margin": Constant.margin], views: views)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[avatarButton(40)]", options: [], metrics: nil, views: views)
        
        let centerYConstraint = NSLayoutConstraint(item: avatarButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
        NSLayoutConstraint.activate([centerYConstraint])
    }
    
    @objc private func avatarTapped(_ sender: UIButton) {
        didSelect?()
    }
}

extension FeedSectionHeaderView: Configurable {
    
    func configure(withPresenter presenter: FeedSectionHeaderViewModelType) {
        nicknameLabel.text = presenter.nickname
        avatarButton.setImage(with: URL(string: presenter.avatar), for: .normal, placeholder: UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width), transformer: .rounded(Constant.avatarSize))
    }
}
