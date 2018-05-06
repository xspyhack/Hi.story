//
//  PhotoCard.swift
//  Himemory
//
//  Created by bl4ckra1sond3tre on 05/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit

protocol PhotoCardModelType {
    var photo: Photo { get }
    var size: CGSize { get }
}

struct PhotoCardModel: PhotoCardModelType {
    let photo: Photo
    let size: CGSize
}

class PhotoCard: Card {
    
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
        
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate(imageView.hi.edges())
    }
}

extension PhotoCard {
    
    func configure(withPresenter presenter: PhotoCardModelType) {
        SafeDispatch.async(onQueue: DispatchQueue.global(qos: .default)) {
            
            _ = fetchImage(with: presenter.photo.asset, targetSize: presenter.size, imageResultHandler: { (image) in
                
                SafeDispatch.async { [weak self] in
                    self?.imageView.image = image
                }
            })
        }
    }
}
