//
//  UIImage+Hi.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 27/02/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

private let screenScale = UIScreen.main.scale

extension Hi where Base: UIImage {
   
    public func resized(to size: CGSize, withTransform transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        
        let pixelSize = CGSize(width: size.width * screenScale, height: size.height * screenScale)
        
        let newRect = CGRect(origin: CGPoint.zero, size: pixelSize).integral
        let transposedRect = CGRect(origin: CGPoint.zero, size: CGSize(width: pixelSize.height, height: pixelSize.width))
        
        guard let cgImage = base.cgImage else {
            return nil
        }
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        guard let bitmapContext = CGContext(data: nil, width: Int(newRect.width), height: Int(newRect.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return nil
        }
        
        bitmapContext.concatenate(transform)
        
        bitmapContext.interpolationQuality = interpolationQuality
        
        bitmapContext.draw(cgImage, in: drawTransposed ? transposedRect : newRect)
        
        guard let newCGImage = bitmapContext.makeImage() else {
            return nil
        }
        
        let image = UIImage(cgImage: newCGImage, scale: screenScale, orientation: base.imageOrientation)
        return image
    }
    
    public func resized(to size: CGSize, withInterpolationQuality interpolationQuality: CGInterpolationQuality) -> UIImage? {
        
        let drawTransposed: Bool
        
        switch base.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        
        let image = resized(to: size, withTransform: transformForOrientation(with: size), drawTransposed: drawTransposed, interpolationQuality: interpolationQuality)
        return image
    }
    
    public func transformForOrientation(with size: CGSize) -> CGAffineTransform {
        
        var transform = CGAffineTransform.identity
        
        switch base.imageOrientation {
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2.0)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2.0)
            
        default:
            break
        }
        
        switch base.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        return transform
    }

}
