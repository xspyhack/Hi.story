//
//  TodayCardView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 04/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol TodayCardViewModelType {
    var text: String { get }
    var date: String { get }
    var imageURL: URL? { get }
    var avatar: URL? { get }
}
struct TodayCardViewModel: TodayCardViewModelType {
    let text: String
    let date: String
    let imageURL: URL?
    let avatar: URL?
    
    init(story: Story, creator: User) {
        
        self.text = story.title != Configuration.Defaults.storyTitle ? story.title : story.body
        self.date = Date(timeIntervalSince1970: story.createdAt).hi.monthDayYear
        self.avatar = URL(string: creator.avatarURLString)
        self.imageURL = (story.attachment?.urlString).flatMap { URL(string: $0) }
    }
}

enum TodayCardViewStyle {
    case top
    case middle
    case bottom
}

final class TodayCardView: UIView, Configurable {

    private struct Constant {
        static let avatarSize = CGSize(width: 40.0, height: 40.0)
    }
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "album")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16.0
        imageView.backgroundColor = UIColor.white
        return imageView
    }()
    
    private(set) lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 16.0
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Welcome to Hi.story"
        label.font = UIFont(name: "Didot-Bold", size: 36.0)
        label.textColor = UIColor.white
        label.numberOfLines = 5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.white
        return label
    }()

    private(set) lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width)
        return imageView
    }()
    
    private(set) var style: TodayCardViewStyle
    
    convenience init(style: TodayCardViewStyle) {
        self.init(frame: .zero)
        
        self.style = style
        
        setup(style)
    }
    
    private override init(frame: CGRect) {
        self.style = .middle
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    fileprivate func setup(_ style: TodayCardViewStyle = .middle) {
       
        backgroundColor = UIColor.clear
        layer.shadowRadius = 12.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 1.0
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .top:
            contentView.addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
        case .middle:
            contentView.addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
        case .bottom:
            contentView.addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "imageView": imageView,
            "overlayView": overlayView,
            "contentView": contentView,
            "textLabel": textLabel,
            "dateLabel": dateLabel,
            "avatarImageView": avatarImageView,
        ]
        
        let imageViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        let imageViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views)
        
        let overlayViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", options: [], metrics: nil, views: views)
        let overlayViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: [], metrics: nil, views: views)
        
        let textLabelConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[textLabel]-16-|", options: [], metrics: nil, views: views)
        
        switch style {
        case .top:
            
            let textLabelV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[textLabel]-8-|", options: [.alignAllCenterX], metrics: nil, views: views)
            NSLayoutConstraint.activate(textLabelV)

            let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-36-[dateLabel]-8-[contentView]-16-[avatarImageView(40.0)]-16-|", options: [.alignAllCenterX], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(vConstraints)
            
        case .middle:
            let textLabelV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[textLabel]-8-[dateLabel]-8-|", options: [.alignAllCenterX], metrics: nil, views: views)
            NSLayoutConstraint.activate(textLabelV)
            
            let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[avatarImageView(40.0)]-16-|", options: [.alignAllCenterX], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(vConstraints)
            
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1.0, constant: -72 * 2).isActive = true
            
        case .bottom:
            let textLabelV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[textLabel]|", options: [.alignAllCenterX], metrics: nil, views: views)
            NSLayoutConstraint.activate(textLabelV)
            
            let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[contentView]-8-[dateLabel]-16-[avatarImageView(40.0)]-16-|", options: [.alignAllCenterX], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(vConstraints)
        }
        
        let contentViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: views)
        
        
        NSLayoutConstraint.activate(imageViewConstraintsH)
        NSLayoutConstraint.activate(imageViewConstraintsV)
        
        NSLayoutConstraint.activate(overlayViewConstraintsH)
        NSLayoutConstraint.activate(overlayViewConstraintsV)
        
        NSLayoutConstraint.activate(textLabelConstraintsH)
        
        NSLayoutConstraint.activate(contentViewH)
        
        
        avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        NSLayoutConstraint(item: avatarImageView, attribute: .width, relatedBy: .equal, toItem: avatarImageView, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    func configure(withPresenter presenter: TodayCardViewModelType) {
        textLabel.text = presenter.text
        dateLabel.text = "- \(presenter.date) -"
        
        let cover = King.all[Defaults.selectingCover.value].card
        imageView.setImage(with: presenter.imageURL, placeholder: cover)
        
        avatarImageView.setImage(with: presenter.avatar, placeholder: UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width), transformer: .rounded(Constant.avatarSize))
        overlayView.isHidden = false
    }
}
