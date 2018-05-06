//
//  UIButton+Hi.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 21/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public extension Hi where Base: UIButton {
    
    public func setImage(with url: URL?,
                  for state: UIControlState,
                  placeholder: UIImage? = nil) {
        setImage(with: url?.absoluteString, for: state, placeholder: placeholder)
    }
    
    public func setImage(with key: String?,
                  for state: UIControlState,
                  placeholder: UIImage? = nil) {

        base.setImage(placeholder, for: state)
        
        guard let key = key else {
            return
        }
        
        ImageCache.shared.retrieve(forKey: key) { [weak base] image, cacheKey in
            SafeDispatch.async {
                guard let sbase = base, let image = image, key == cacheKey else {
                    return
                }
                
                sbase.setImage(image, for: state)
            }
        }
    }
    
    public func setBackgroundImage(with url: URL?,
                            for state: UIControlState,
                            placeholder: UIImage? = nil) {
        setBackgroundImage(with: url?.absoluteString, for: state, placeholder: placeholder)
    }
    
    public func setBackgroundImage(with key: String?,
                            for state: UIControlState,
                            placeholder: UIImage? = nil) {
        
        base.setBackgroundImage(placeholder, for: state)
        
        guard let key = key else {
            return
        }
        
        ImageCache.shared.retrieve(forKey: key) { [weak base] image, cacheKey in
            SafeDispatch.async {
                guard let sbase = base, let image = image, key == cacheKey else {
                    return
                }
                
                sbase.setBackgroundImage(image, for: state)
            }
        }
    }
}
