//
//  FeedImageCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 23/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol FeedImageCellModelType {
    var title: String { get }
    var body: String { get }
    var imageURL: String? { get }
    var thumbnailData: Data? { get }
}

struct FeedImageCellModel: FeedImageCellModelType {
    
    let title: String
    let body: String
    let imageURL: String?
    let thumbnailData: Data?
    
    init(story: Story) {
        self.title = story.title
        self.body = story.body
        self.imageURL = story.attachment?.urlString
        self.thumbnailData = story.attachment?.thumbnailImageData
    }
}

class FeedImageCell: UICollectionViewCell, Reusable {
    
    static let margin: CGFloat = 16.0
    
    private lazy var imageView: UIImageView = {
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
        label.textColor = UIColor.hi.title
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
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
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[titleLabel]-(margin)-|", options: [], metrics: ["margin": FeedImageCell.margin], views: views)
        
        let imageViewHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        
        let imageViewVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]-16-[titleLabel]", options: [], metrics: nil, views: views)
        let imageViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 9.0 / 16.0, constant: 0.0)
        
        NSLayoutConstraint.activate(imageViewHConstraints)
        NSLayoutConstraint.activate(imageViewVConstraints)
        NSLayoutConstraint.activate([imageViewHeightConstraint])
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLabel]-16-[bodyLabel]-32-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
    }
}

extension FeedImageCell: Configurable {
    
    func configure(withPresenter presenter: FeedImageCellModelType) {
        titleLabel.text = presenter.title
        bodyLabel.text = presenter.body
        
        if let url = presenter.imageURL, url.isEmpty, let thumbnailData = presenter.thumbnailData {
            DispatchQueue.global(qos: .default).async {
                if let image = UIImage(data: thumbnailData)?.hi.normalized {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        } else {
            imageView.hi.setImage(with: presenter.imageURL.flatMap { URL(string: $0) })
        }
    }
}
