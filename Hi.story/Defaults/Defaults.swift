//
//  Defaults.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

fileprivate let prefix = "com.xspyhack.History"

struct Defaults {
    
    static let userDefaults = UserDefaults.standard
    
    struct Color {
        static let tint = "#1BBBBB"
        static let from = "#1EEEEE"
        static let to = "#133333"
        static let border = "#EEEEEE"
        static let separator = "#DDDDDD"
        static let text = "#353535"
        static let placeholder = "#C7C7C7"
    }
    
    static let uuidKey = prefix + ".uuid"
    
    static let navigationBarWithoutStatusBarHeight: CGFloat = 44.0
    static let tabBarHeight: CGFloat = 44.0
    static let rowHeight: CGFloat = 48.0
    
    static let presentedViewControllerHeight: CGFloat = 440.0
    
    static let statusBarHeight: CGFloat = 20.0
    
    static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 60.0
    
    static var hadShowedNewMatterTip: Bool {
        get {
            return userDefaults.bool(forKey: prefix + ".isShowedNewMatterTip")
        }
        set {
            userDefaults.set(newValue, forKey: prefix + ".isShowedNewMatterTip")
        }
    }
}

class Wrapper<T> {
    let candy: T
    
    init(bullet: T) {
        self.candy = bullet
    }
}
