//
//  UIImageView+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 21/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit

public extension Hi where Base: UIImageView {
    
    public func setImage(with url: URL?, placeholder: UIImage? = nil, fadeIn: Bool = true) {
        setImage(with: url?.absoluteString, placeholder: placeholder, fadeIn: fadeIn)
    }
    
    public func setImage(with key: String?, placeholder: UIImage? = nil, fadeIn: Bool = true) {
        
        guard let key = key else {
            self.placeholder = placeholder
            return
        }
        
        if base.image == nil && self.placeholder == nil {
            self.placeholder = placeholder
        }
        
        ImageCache.shared.retrieve(forKey: key) { [weak base] image, cacheKey in
            SafeDispatch.async {
                guard let sbase = base, let image = image, key == cacheKey else {
                    return
                }
                
                guard fadeIn else {
                    self.placeholder = nil
                    sbase.image = image
                    return
                }
                
                // 外面一层很重要，在 reuse 的时候，能去掉从上一次的图片转换到当前的错误效果
                UIView.transition(with: sbase, duration: 0.0, options: [],
                                  animations: { },
                                  completion: { _ in
                                    self.placeholder = nil
                                    UIView.transition(with: sbase, duration: 0.3,
                                                      options: [.transitionCrossDissolve, .allowUserInteraction],
                                                      animations: {
                                                        sbase.image = image
                                                      }, completion: { finished in
                                                      })
                                  })
            }
        }
    }
}

private var placeholderKey: Void?

extension Hi where Base: UIImageView {
    
    public fileprivate(set) var placeholder: UIImage? {
        get {
            return objc_getAssociatedObject(base, &placeholderKey) as? UIImage
        }
        
        set {
            base.image = newValue
            objc_setAssociatedObject(base, &placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
