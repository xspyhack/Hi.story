//
//  ActivityCroppedImageProvider.swift
//  Cropper
//
//  Created by bl4ckra1sond3tre on 06/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class ActivityCroppedImageProvider: UIActivityItemProvider {

    private(set) var image: UIImage
    private(set) var cropFrame: CGRect
    private(set) var angle: Int
    private(set) var circular: Bool
    
    private var croppedImage: UIImage?
    
    init(image: UIImage, cropFrame: CGRect, angle: Int, circular: Bool) {
        self.image = image
        self.cropFrame = cropFrame
        self.angle = angle
        self.circular = circular
        
        super.init(placeholderItem: UIImage())
    }
    
    // MARK: - UIActivity Protocols
    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage()
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return croppedImage
    }
    
    override var item: Any {
        
        //If the user didn't touch the image, just forward along the original
        if self.angle == 0 && self.cropFrame.equalTo(CGRect(origin: .zero, size: self.image.size)) {
            self.croppedImage = self.image
            return self.croppedImage!
        } else {
            let image = self.image.hi.cropped(with: cropFrame, angle: angle, circularClip: circular)
            self.croppedImage = image
            return self.croppedImage ?? self.image
        }
    }
    
}
