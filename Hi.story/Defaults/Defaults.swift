//
//  Defaults.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

struct Defaults {
    
    static let userDefaults = UserDefaults.standard
   
    struct Key {
        static let prefix = "com.xspyhack.History."
        
        static let userID = prefix + "userID"
        static let nickname = prefix + "nickname"
        static let bio = prefix + "bio"
        static let avatar = prefix + "avatar"
        
        static let sayHi = prefix + "sayHi"
        
        static let uuidKey = prefix + "uuid"
        
        static let showedNewMatterTip = prefix + "showedNewMatterTip"
    }
    
    static let navigationBarWithoutStatusBarHeight: CGFloat = 44.0
    static let tabBarHeight: CGFloat = 44.0
    static let rowHeight: CGFloat = 48.0
    
    static let presentedViewControllerHeight: CGFloat = 440.0
    
    static let statusBarHeight: CGFloat = 20.0
    
    static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 60.0
    
    static var showedNewMatterTip: Bool {
        get {
            return userDefaults.bool(forKey: Key.showedNewMatterTip)
        }
        set {
            userDefaults.set(newValue, forKey: Key.showedNewMatterTip)
        }
    }
    
    static var sayHi: Bool {
        get {
            return userDefaults.bool(forKey: Key.sayHi)
        }
        set {
            userDefaults.set(newValue, forKey: Key.sayHi)
        }
    }
}

class Wrapper<T> {
    let candy: T
    
    init(bullet: T) {
        self.candy = bullet
    }
}
