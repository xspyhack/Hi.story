//
//  ImageProcessor.swift
//  Kingfisher
//
//  Created by Wei Wang on 2016/08/26.
//
//  Copyright (c) 2016 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import CoreGraphics
import Hikit

/// The item which could be processed by an `ImageProcessor`
///
/// - image: Input image
/// - data:  Input data
public enum ImageProcessItem {
    case image(UIImage)
    case data(Data)
}

/// An `ImageProcessor` would be used to convert some downloaded data to an image.
public protocol ImageProcessor {
    /// Identifier of the processor. It will be used to identify the processor when
    /// caching and retriving an image. You might want to make sure that processors with
    /// same properties/functionality have the same identifiers, so correct processed images
    /// could be retrived with proper key.
    ///
    /// - Note: Do not supply an empty string for a customized processor, which is already taken by
    /// the `DefaultImageProcessor`. It is recommended to use a reverse domain name notation
    /// string of your own for the identifier.
    var identifier: String { get }
    
    /// Process an input `ImageProcessItem` item to an image for this processor.
    ///
    /// - parameter item:    Input item which will be processed by `self`
    /// - parameter options: Options when processing the item.
    ///
    /// - returns: The processed image.
    ///
    /// - Note: The return value will be `nil` if processing failed while converting data to image.
    ///         If input item is already an image and there is any errors in processing, the input
    ///         image itself will be returned.
    /// - Note: Most processor only supports CG-based images.
    ///         watchOS is not supported for processers containing filter, the input image will be returned directly on watchOS.
    func process(item: ImageProcessItem, options: OptionsInfo) -> UIImage?
}

typealias ProcessorImp = ((ImageProcessItem, OptionsInfo) -> UIImage?)

public extension ImageProcessor {
    
    /// Append an `ImageProcessor` to another. The identifier of the new `ImageProcessor`
    /// will be "\(self.identifier)|>\(another.identifier)".
    ///
    /// - parameter another: An `ImageProcessor` you want to append to `self`.
    ///
    /// - returns: The new `ImageProcessor`. It will process the image in the order
    ///            of the two processors concatenated.
    public func append(another: ImageProcessor) -> ImageProcessor {
        let newIdentifier = identifier.appending("|>\(another.identifier)")
        return GeneralProcessor(identifier: newIdentifier) {
            item, options in
            if let image = self.process(item: item, options: options) {
                return another.process(item: .image(image), options: options)
            } else {
                return nil
            }
        }
    }
}

fileprivate struct GeneralProcessor: ImageProcessor {
    let identifier: String
    let p: ProcessorImp
    func process(item: ImageProcessItem, options: OptionsInfo) -> UIImage? {
        return p(item, options)
    }
}

/// The default processor. It convert the input data to a valid image.
/// Images of .PNG, .JPEG and .GIF format are supported.
/// If an image is given, `DefaultImageProcessor` will do nothing on it and just return that image.
public struct DefaultImageProcessor: ImageProcessor {
    
    /// A default `DefaultImageProcessor` could be used across.
    public static let `default` = DefaultImageProcessor()
    
    public let identifier = ""
    
    /// Initialize a `DefaultImageProcessor`
    ///
    /// - returns: An initialized `DefaultImageProcessor`.
    public init() {}
    
    public func process(item: ImageProcessItem, options: OptionsInfo) -> UIImage? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            return Hi<UIImage>.image(data: data, scale: options.scaleFactor)
        }
    }
}

/// Processor for making round corner images. Only CG-based images are supported in macOS,
/// if a non-CG image passed in, the processor will do nothing.
public struct RoundCornerImageProcessor: ImageProcessor {
    public let identifier: String
    
    /// Corner radius will be applied in processing.
    public let cornerRadius: CGFloat
    
    /// Target size of output image should be. If `nil`, the image will keep its original size after processing.
    public let targetSize: CGSize?
    
    /// Initialize a `RoundCornerImageProcessor`
    ///
    /// - parameter cornerRadius: Corner radius will be applied in processing.
    /// - parameter targetSize:   Target size of output image should be. If `nil`,
    ///                           the image will keep its original size after processing.
    ///                           Default is `nil`.
    ///
    /// - returns: An initialized `RoundCornerImageProcessor`.
    public init(cornerRadius: CGFloat, targetSize: CGSize? = nil) {
        self.cornerRadius = cornerRadius
        self.targetSize = targetSize
        if let size = targetSize {
            self.identifier = "com.onevcat.Kingfisher.RoundCornerImageProcessor(\(cornerRadius)_\(size))"
        } else {
            self.identifier = "com.onevcat.Kingfisher.RoundCornerImageProcessor(\(cornerRadius))"
        }
    }
    
    public func process(item: ImageProcessItem, options: OptionsInfo) -> UIImage? {
        switch item {
        case .image(let image):
            let size = targetSize ?? image.hi.size
            return image.hi.image(withRoundRadius: cornerRadius, fit: size)
        case .data(_):
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
    }
}

/// Processor for resizing images. Only CG-based images are supported in macOS.
public struct ResizingImageProcessor: ImageProcessor {
    public let identifier: String
    
    /// Target size of output image should be.
    public let targetSize: CGSize
    
    /// Initialize a `ResizingImageProcessor`
    ///
    /// - parameter targetSize: Target size of output image should be.
    ///
    /// - returns: An initialized `ResizingImageProcessor`.
    public init(targetSize: CGSize) {
        self.targetSize = targetSize
        self.identifier = "com.onevcat.Kingfisher.ResizingImageProcessor(\(targetSize))"
    }
    
    public func process(item: ImageProcessItem, options: OptionsInfo) -> UIImage? {
        switch item {
        case .image(let image):
            return image.hi.resize(to: targetSize)
        case .data(_):
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
    }
}

/// Processor for adding blur effect to images. `Accelerate.framework` is used underhood for
/// a better performance. A simulated Gaussian blur with specified blur radius will be applied.
public struct BlurImageProcessor: ImageProcessor {
    public let identifier: String
    
    /// Blur radius for the simulated Gaussian blur.
    public let blurRadius: CGFloat
    
    /// Initialize a `BlurImageProcessor`
    ///
    /// - parameter blurRadius: Blur radius for the simulated Gaussian blur.
    ///
    /// - returns: An initialized `BlurImageProcessor`.
    public init(blurRadius: CGFloat) {
        self.blurRadius = blurRadius
        self.identifier = "com.onevcat.Kingfisher.BlurImageProcessor(\(blurRadius))"
    }
    
    public func process(item: ImageProcessItem, options: OptionsInfo) -> UIImage? {
        switch item {
        case .image(let image):
            let radius = blurRadius * options.scaleFactor
            return image.hi.blurred(withRadius: radius)
        case .data(_):
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
    }
}

/// Concatenate two `ImageProcessor`s. `ImageProcessor.appen(another:)` is used internally.
///
/// - parameter left:  First processor.
/// - parameter right: Second processor.
///
/// - returns: The concatenated processor.
public func >>(left: ImageProcessor, right: ImageProcessor) -> ImageProcessor {
    return left.append(another: right)
}

fileprivate extension UIColor {
    var hex: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rInt = Int(r * 255) << 24
        let gInt = Int(g * 255) << 16
        let bInt = Int(b * 255) << 8
        let aInt = Int(a * 255)
        
        let rgba = rInt | gInt | bInt | aInt
        
        return String(format:"#%08x", rgba)
    }
}
