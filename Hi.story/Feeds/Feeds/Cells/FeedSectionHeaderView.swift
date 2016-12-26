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
    
    static let margin: CGFloat = 16.0
    
    fileprivate lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "avatar"), for: .normal)
        button.addTarget(self, action: #selector(avatarTapped(_:)), for: .touchUpInside)
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
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[avatarButton(40)]-16-[nicknameLabel]-(>=10)-[moreButton(44)]-(margin)-|", options: [.alignAllCenterY], metrics: ["margin": FeedSectionHeaderView.margin], views: views)
        
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
        avatarButton.setImage(UIImage(named: presenter.avatar), for: .normal)
    }
}
