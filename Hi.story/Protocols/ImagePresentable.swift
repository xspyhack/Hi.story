//
//  ImagePresentable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol ImagePresentable {
    var imageName: String? { get }
    
    var imageURLString: String? { get }
    
    func updateImageView(_ imageView: UIImageView)
}

extension ImagePresentable {
    var imageName: String? { return nil }
    
    var imageURLString: String? { return nil }
    
    func updateImageView(_ imageView: UIImageView) {
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        } else {
            assert(false, "Must implemetation updateImageView method.")
        }
    }
}
