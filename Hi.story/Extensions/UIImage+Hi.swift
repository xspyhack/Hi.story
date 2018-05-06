//
//  UIImage+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Accelerate
import CoreImage
import Hikit

protocol ImageTransformer {
    
    var transform: (CIImage) -> CIImage? { get }
}

extension UIImage {
    
    static let ciContext = CIContext(options: nil)
    
    static let ciContextFast = CIContext(eaglContext: EAGLContext(api: EAGLRenderingAPI.openGLES2)!, options: [kCIContextWorkingColorSpace: NSNull()])
}

extension Hi where Base: UIImage {
    
    func apply(_ transformer: ImageTransformer) -> UIImage {
        
        guard let cgImage = cgImage else {
            assertionFailure("Transform image only works for CG-based image.")
            return base
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        guard let outputImage = transformer.transform(inputImage) else {
            return base
        }
        
        guard let filteredImageRef = UIImage.ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            assertionFailure("Can not transfrom image within context.")
            return base
        }
        
        return Hi.image(cgImage: filteredImageRef, scale: scale, refImage: base)
    }
    
    func draw(cgImage: CGImage?, to size: CGSize, draw: () -> Void) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw()
        return UIGraphicsGetImageFromCurrentImageContext() ?? base
    }
}

// https://github.com/onevcat/Kingfisher/blob/master/Sources/Image.swift

extension UIImage {
    
    func tinted(_ color: UIColor) -> UIImage {
        return tinted(color, blendMode: .destinationIn)
    }
    
    func gradientTinted(_ color: UIColor) -> UIImage {
        return tinted(color, blendMode: .overlay)
    }
    
    private func tinted(_ tintColor: UIColor, blendMode: CGBlendMode) -> UIImage {
        //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        tintColor.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        
        //Draw the tinted image in context
        draw(in: bounds, blendMode: blendMode, alpha: 1.0)
        if blendMode != .destinationIn {
            draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        }
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return tintedImage!
    }
}

// MARK: - Image Properties
extension Hi where Base: UIImage {
    
    var cgImage: CGImage? {
        return base.cgImage
    }
    
    var scale: CGFloat {
        return base.scale
    }
    
    var size: CGSize {
        return base.size
    }
}

// MARK: - Image Conversion
extension Hi where Base: UIImage {
    
    static func image(cgImage: CGImage, scale: CGFloat, refImage: UIImage?) -> UIImage {
        if let refImage = refImage {
            return UIImage(cgImage: cgImage, scale: scale, orientation: refImage.imageOrientation)
        } else {
            return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        }
    }
    
    /**
     Normalize the image. This method will try to redraw an image with orientation and scale considered.
     
     - returns: The normalized image with orientation set to up and correct scale.
     */
    public var normalized: UIImage {
        // No need to do anything if already up
        guard base.imageOrientation != .up else { return base }
        
        return draw(cgImage: nil, to: size) {
            base.draw(in: CGRect(origin: CGPoint.zero, size: size))
        }
    }
}

// MARK: - Image Representation
extension Hi where Base: UIImage {
    // MARK: - PNG
    func pngRepresentation() -> Data? {
        return UIImagePNGRepresentation(base)
    }
    
    // MARK: - JPEG
    func jpegRepresentation(compressionQuality: CGFloat) -> Data? {
        return UIImageJPEGRepresentation(base, compressionQuality)
    }
}

extension Hi where Base: UIImage {
    
    static func image(data: Data, scale: CGFloat) -> UIImage? {
        var image: UIImage?

        switch data.hi.imageFormat {
        case .jpeg: image = UIImage(data: data, scale: scale)
        case .png: image = UIImage(data: data, scale: scale)
        case .gif: image = UIImage(data: data, scale: scale)
        case .unknown: image = UIImage(data: data, scale: scale)
        }
        
        return image
    }
}

// MARK: - Image Transforming
extension Hi where Base: UIImage {
    
    // MARK: - Round Corner
    /// Create a round corner image based on `self`.
    ///
    /// - parameter radius: The round corner radius of creating image.
    /// - parameter size:   The target size of creating image.
    ///
    /// - returns: An image with round corner of `self`.
    ///
    /// - Note: This method only works for CG-based image.
    public func image(withRoundRadius radius: CGFloat, fit size: CGSize) -> UIImage {
        
        guard let cgImage = cgImage else {
            assertionFailure("Round corder image only works for CG-based image.")
            return base
        }
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        return draw(cgImage: cgImage, to: size) {
            guard let context = UIGraphicsGetCurrentContext() else {
                assertionFailure("Failed to create CG context for image.")
                return
            }
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
            context.addPath(path)
            context.clip()
            base.draw(in: rect)
        }
    }
    
    func resize(to size: CGSize, for contentMode: UIViewContentMode) -> UIImage {
        switch contentMode {
        case .scaleAspectFit:
            let newSize = self.size.hi.constrained(size)
            return resize(to: newSize)
        case .scaleAspectFill:
            let newSize = self.size.hi.filling(size)
            return resize(to: newSize)
        default:
            return resize(to: size)
        }
    }
    
    // MARK: - Resize
    
    /// Resize `self` to an image of new size.
    ///
    /// - parameter size: The target size.
    ///
    /// - returns: An image with new size.
    ///
    /// - Note: This method only works for CG-based image.
    public func resize(to size: CGSize) -> UIImage {
        
        guard let cgImage = cgImage else {
            assertionFailure("Resize only works for CG-based image.")
            return base
        }
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        return draw(cgImage: cgImage, to: size) {
            base.draw(in: rect)
        }
    }
    
    // MARK: - Blur
    
    /// Create an image with blur effect based on `self`.
    ///
    /// - parameter radius: The blur radius should be used when creating blue.
    ///
    /// - returns: An image with blur effect applied.
    ///
    /// - Note: This method only works for CG-based image.
    public func blurred(withRadius radius: CGFloat) -> UIImage {
        guard let cgImage = cgImage else {
            assertionFailure("Blur only works for CG-based image.")
            return base
        }
        
        // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
        // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
        // if d is odd, use three box-blurs of size 'd', centered on the output pixel.
        let s = max(radius, 2.0)
        // We will do blur on a resized image (*0.5), so the blur radius could be half as well.
        var targetRadius = floor((Double(s * 3.0) * sqrt(2 * .pi) / 4.0 + 0.5))
        
        if targetRadius.isEven {
            targetRadius += 1
        }
        
        let iterations: Int
        if radius < 0.5 {
            iterations = 1
        } else if radius < 1.5 {
            iterations = 2
        } else {
            iterations = 3
        }
        
        let w = Int(size.width)
        let h = Int(size.height)
        let rowBytes = Int(CGFloat(cgImage.bytesPerRow))
        
        let inDataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: rowBytes * Int(h))
        inDataPointer.initialize(to: 0)
        defer {
            inDataPointer.deinitialize(count: rowBytes * Int(h))
            inDataPointer.deallocate()
        }
            
        let bitmapInfo = cgImage.bitmapInfo.fixed
        guard let context = CGContext(data: inDataPointer,
                                      width: w,
                                      height: h,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: rowBytes,
                                      space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: bitmapInfo.rawValue) else
        {
            assertionFailure("Failed to create CG context for blurring image.")
            return base
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
        
        
        var inBuffer = vImage_Buffer(data: inDataPointer, height: vImagePixelCount(h), width: vImagePixelCount(w), rowBytes: rowBytes)
        
        let outDataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: rowBytes * Int(h))
        outDataPointer.initialize(to: 0)
        defer {
            outDataPointer.deinitialize(count: rowBytes * Int(h))
            outDataPointer.deallocate()
        }
            
        var outBuffer = vImage_Buffer(data: outDataPointer, height: vImagePixelCount(h), width: vImagePixelCount(w), rowBytes: rowBytes)
        
        for _ in 0 ..< iterations {
            vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(targetRadius), UInt32(targetRadius), nil, vImage_Flags(kvImageEdgeExtend))
            (inBuffer, outBuffer) = (outBuffer, inBuffer)
        }
        
        guard let outContext = CGContext(data: inDataPointer,
                                         width: w,
                                         height: h,
                                         bitsPerComponent: cgImage.bitsPerComponent,
                                         bytesPerRow: rowBytes,
                                         space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                         bitmapInfo: bitmapInfo.rawValue) else
        {
            assertionFailure("Failed to create CG context for blurring image.")
            return base
        }
        
        let result = outContext.makeImage().flatMap { UIImage(cgImage: $0, scale: base.scale, orientation: base.imageOrientation) }

        guard let blurredImage = result else {
            assertionFailure("Can not make an blurred image within this context.")
            return base
        }
        
        return blurredImage
    }
    
    // MARK: - Overlay
    
    /// Create an image from `self` with a color overlay layer.
    ///
    /// - parameter color:    The color should be use to overlay.
    /// - parameter fraction: Fraction of input color. From 0.0 to 1.0. 0.0 means solid color, 1.0 means transparent overlay.
    ///
    /// - returns: An image with a color overlay applied.
    ///
    /// - Note: This method only works for CG-based image.
    public func overlaying(with color: UIColor, fraction: CGFloat) -> UIImage {
        
        guard let cgImage = cgImage else {
            assertionFailure("Overlaying only works for CG-based image.")
            return base
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return draw(cgImage: cgImage, to: rect.size) {
            color.set()
            UIRectFill(rect)
            base.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
            
            if fraction > 0 {
                base.draw(in: rect, blendMode: .sourceAtop, alpha: fraction)
            }
        }
    }
}

// MARK: - Decode
extension Hi where Base: UIImage {
    var decoded: UIImage? {
        return decoded(scale: scale)
    }
    
    func decoded(scale: CGFloat) -> UIImage {
        guard let imageRef = self.cgImage else {
            assertionFailure("Decoding only works for CG-based image.")
            return base
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = imageRef.bitmapInfo.fixed
        
        guard let context = CGContext(data: nil, width: imageRef.width, height: imageRef.height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            assertionFailure("Decoding fails to create a valid context.")
            return base
        }
        
        let rect = CGRect(x: 0, y: 0, width: imageRef.width, height: imageRef.height)
        context.draw(imageRef, in: rect)
        let decompressedImageRef = context.makeImage()
        return Hi<UIImage>.image(cgImage: decompressedImageRef!, scale: scale, refImage: base)
    }
}

// MARK: - Image format
private struct ImageHeaderData {
    static var png: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    static var jpeg_soi: [UInt8] = [0xFF, 0xD8]
    static var jpeg_if: [UInt8] = [0xFF]
    static var gif: [UInt8] = [0x47, 0x49, 0x46]
}

enum ImageFormat {
    case unknown, png, jpeg, gif
}

// MARK: - Misc Helpers

extension Data: HistoryCompatible {
}

extension Hi where Base == Data {
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 8)
        (base as NSData).getBytes(&buffer, length: 8)
        if buffer == ImageHeaderData.png {
            return .png
        } else if buffer[0] == ImageHeaderData.jpeg_soi[0] &&
            buffer[1] == ImageHeaderData.jpeg_soi[1] &&
            buffer[2] == ImageHeaderData.jpeg_if[0]
        {
            return .jpeg
        } else if buffer[0] == ImageHeaderData.gif[0] &&
            buffer[1] == ImageHeaderData.gif[1] &&
            buffer[2] == ImageHeaderData.gif[2]
        {
            return .gif
        }
        
        return .unknown
    }
}

extension CGSize: HistoryCompatible {
}

extension Hi where Base == CGSize {
    func constrained(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        return aspectWidth > size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }
    
    func filling(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        return aspectWidth < size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }
    
    private var aspectRatio: CGFloat {
        return base.height == 0.0 ? 1.0 : base.width / base.height
    }
}

extension CGBitmapInfo {
    var fixed: CGBitmapInfo {
        var fixed = self
        let alpha = (rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
        if alpha == CGImageAlphaInfo.none.rawValue {
            fixed.remove(.alphaInfoMask)
            fixed = CGBitmapInfo(rawValue: fixed.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
        } else if !(alpha == CGImageAlphaInfo.noneSkipFirst.rawValue) || !(alpha == CGImageAlphaInfo.noneSkipLast.rawValue) {
            fixed.remove(.alphaInfoMask)
            fixed = CGBitmapInfo(rawValue: fixed.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        }
        return fixed
    }
}

extension CGContext {
    static func createARGBContext(from imageRef: CGImage) -> CGContext? {
        
        let w = imageRef.width
        let h = imageRef.height
        let bytesPerRow = w * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let data = malloc(bytesPerRow * h)
        defer {
            free(data)
        }
        
        let bitmapInfo = imageRef.bitmapInfo.fixed
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here.
        return CGContext(data: data,
                         width: w,
                         height: h,
                         bitsPerComponent: imageRef.bitsPerComponent,
                         bytesPerRow: bytesPerRow,
                         space: colorSpace,
                         bitmapInfo: bitmapInfo.rawValue)
    }
}

extension Double {
    var isEven: Bool {
        return truncatingRemainder(dividingBy: 2.0) == 0
    }
}
