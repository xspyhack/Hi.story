//
//  ZoomableImageView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class ZoomableImageView: UIScrollView, UIScrollViewDelegate {

    var imageView = UIImageView()

    var imageSize: CGSize?

    var image: UIImage! = nil {
        didSet {

            if image != nil {

                if !imageView.isDescendant(of: self) {
                    self.imageView.alpha = 1.0
                    self.addSubview(imageView)
                }

            } else {

                imageView.image = nil
                return
            }

            let imageSize = self.imageSize ?? image.size

            if imageSize.width < self.frame.width || imageSize.height < self.frame.height {

                // The width or height of the image is smaller than the frame size

                if imageSize.width > imageSize.height {

                    // Width > Height

                    let ratio = self.frame.width / imageSize.width

                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: self.frame.width, height: imageSize.height * ratio)
                    )

                } else {

                    // Width <= Height

                    let ratio = frame.height / imageSize.height

                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: imageSize.width * ratio, height: frame.size.height)
                    )

                }

                imageView.center = center

            } else {

                // The width or height of the image is bigger than the frame size

                if imageSize.width > imageSize.height {

                    // Width > Height

                    let ratio = frame.height / imageSize.height

                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: imageSize.width * ratio, height: frame.height)
                    )

                } else {

                    // Width <= Height

                    let ratio = frame.width / imageSize.width

                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: frame.width, height: imageSize.height * ratio)
                    )

                }

                self.contentOffset = CGPoint(
                    x: imageView.center.x - center.x,
                    y: imageView.center.y - center.y
                )
            }

            contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)

            imageView.image = image

            zoomScale = 1.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        setup()
    }

    private func setup() {

        self.frame.size = CGSize.zero
        self.imageView.alpha = 0.0

        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)

        self.maximumZoomScale = 2.0
        self.minimumZoomScale = 1.0
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator   = false
        self.bouncesZoom = true
        self.bounces = true

        self.isScrollEnabled = true
        
        self.delegate = self
    }

    func setScrollable(isScrollable: Bool) {
        
        self.isScrollEnabled = isScrollable
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
}
