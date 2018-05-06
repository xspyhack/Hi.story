//
//  PhotoItemCell.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

protocol PhotoItemCellModelType {
    var photo: Photo { get }
    var size: CGSize { get }
}

struct PhotoItemCellModel: PhotoItemCellModelType {
    let photo: Photo
    let size: CGSize
}

class PhotoItemCell: HistoryItemCell, Reusable {
   
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        iconImageView.image = UIImage.hi.photosIcon
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "imageView": imageView,
            "iconView": iconView
        ]
        
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:[iconView][imageView]|", options: [.alignAllTrailing, .alignAllLeading], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(v)
    }
    
    static func height(with photo: Photo, width: CGFloat) -> CGFloat {
        return width / photo.ratio + HistoryItemCell.iconContainerHeight
    }
}

extension PhotoItemCell: Configurable {
    
    func configure(withPresenter presenter: PhotoItemCellModelType) {
       
        createdAtLabel.text = Date(timeIntervalSince1970: presenter.photo.createdAt).hi.time
        
        SafeDispatch.async(onQueue: DispatchQueue.global(qos: .default)) {
            
            _ = fetchImage(with: presenter.photo.asset, targetSize: presenter.size, imageResultHandler: { (image) in
                
                SafeDispatch.async { [weak self] in
                    self?.imageView.image = image
                }
            })
        }
    }
}
