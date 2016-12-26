//
//  CroppedImageAttributes.swift
//  Cropper
//
//  Created by bl4ckra1sond3tre on 06/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

struct CroppedImageAttributes {
    
    private(set) var angle: Int = 0
    private(set) var croppedFrame: CGRect = .zero
    private(set) var originalImageSize: CGSize = .zero
    
    init(croppedFrame: CGRect, angle: Int, originalImageSize originalSize: CGSize) {
        self.angle = angle
        self.croppedFrame = croppedFrame
        self.originalImageSize = originalSize
    }
}
