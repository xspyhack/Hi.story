//
//  ProfileCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 27/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

final class ProfileCell: UITableViewCell, Reusable {

    fileprivate lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    fileprivate lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.hi.title
        return label
    }()
    
    fileprivate lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.text = "Bio"
        label.textColor = UIColor.hi.description
        return label
    }()
    
    fileprivate struct Constant {
        static let avatarSize = CGSize(width: 60.0, height: 60.0)
    }
    
    private struct Listener {
        static let avatar = "ProfileCell.avatar"
        static let nickname = "ProfileCell.nickname"
        static let bio = "ProfileCell.bio"
    }
  
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        
        accessoryType = .disclosureIndicator
        
        HiUserDefaults.nickname.bindAndFireListener(with: Listener.nickname) { [weak self] (nickname) in
            self?.nicknameLabel.text = nickname
        }
        
        HiUserDefaults.bio.bindAndFireListener(with: Listener.bio) { [weak self] (bio) in
            self?.bioLabel.text = bio
        }
        
        HiUserDefaults.avatar.bindAndFireListener(with: Listener.avatar) { [weak self] avatarURLString in
            self?.avatarImageView.setImage(with: avatarURLString.flatMap { URL(string: $0) }, placeholder: UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width / 2), transformer: .rounded(Constant.avatarSize))
        }
        
        contentView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nicknameLabel)
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bioLabel)
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "avatarImageView": avatarImageView,
            "nicknameLabel": nicknameLabel,
            "bioLabel": bioLabel,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[avatarImageView(60.0)]-12-[nicknameLabel]-(>=20)-|", options: [], metrics: nil, views: views)
        
        let avatarRatio = NSLayoutConstraint(item: avatarImageView, attribute: .height, relatedBy: .equal, toItem: avatarImageView, attribute: .width, multiplier: 1.0, constant: 0.0)
        
        avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate([avatarRatio])
        
        nicknameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 6.0).isActive = true
        bioLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -6.0).isActive = true
        
        bioLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        bioLabel.trailingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor).isActive = true
    }
}

extension ProfileCell: Configurable {
    
    func configure(withPresenter presenter: ProfileCellModelType) {
        nicknameLabel.text = presenter.nickname
        bioLabel.text = presenter.bio
        avatarImageView.setImage(with: presenter.avatar, placeholder: UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width / 2), transformer: .rounded(Constant.avatarSize))
    }
}
