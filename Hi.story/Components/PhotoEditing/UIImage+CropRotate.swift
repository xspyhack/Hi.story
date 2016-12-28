//
//  UIImage+CropRotate.swift
//  Cropper
//
//  Created by bl4ckra1sond3tre on 06/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit

extension Hi where Base: UIImage {
    
    func cropped(with frame: CGRect, angle: Int, circularClip circular: Bool) -> UIImage {
        
        assert(!frame.isEmpty, "Cropped frame can not be empty!")
        
        let croppedImage: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(frame.size, !hasAlpha() && !circular, base.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        do {
            
            guard let context = UIGraphicsGetCurrentContext() else {
                assertionFailure("Failed to create CG context for image.")
                return base
            }
            
            if circular {
                var circularSize = frame.size
                if frame.width != frame.height {
                    let radius = min(frame.width, frame.height)
                    circularSize = CGSize(width: radius, height: radius)
                }
                context.addEllipse(in: CGRect(origin: .zero, size: circularSize))
                context.clip()
            }
            
            //To conserve memory in not needing to completely re-render the image re-rotated,
            //map the image to a view and then use Core Animation to manipulate its rotation
            
            if angle != 0 {
                let imageView = UIImageView(image: base)
                imageView.layer.minificationFilter = kCAFilterNearest
                imageView.layer.magnificationFilter = kCAFilterNearest
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(angle) * (CGFloat.pi / 180.0))
                let rotatedRect = imageView.bounds.applying(imageView.transform)
                let containerView = UIView(frame: CGRect(origin: .zero, size: rotatedRect.size))
                containerView.addSubview(imageView)
                imageView.center = containerView.center
                context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
                containerView.layer.render(in: context)
            } else {
                context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
                base.draw(at: .zero)
            }
            
            croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        guard let croppedCgImage = croppedImage?.cgImage else { return base }
        
        return UIImage(cgImage: croppedCgImage, scale: UIScreen.main.scale, orientation: .up)
    }
    
    private func hasAlpha() -> Bool {
        guard let alphaInfo = base.cgImage?.alphaInfo else { return false }
        
        return alphaInfo == .first || alphaInfo == .last || alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
    }
}
