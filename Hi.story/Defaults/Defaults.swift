//
//  Defaults.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import TextAttributes

struct Defaults {
    
    static let userDefaults = NSUserDefaults.standardUserDefaults()
    
    struct Color {
        static let tintColor = "#1BBBBB"
        static let fromColor = "#1EEEEE"
        static let toColor = "#133333"
        static let border = "#EEEEEE"
        static let separator = "#DDDDDD"
        static let textColor = "#353535"
        static let placeholder = "#C7C7C7"
    }
    
    struct Authentication {
        static let tokenKey = "History.Authentication.Token"
        static var token: String? {
            get {
                return userDefaults.objectForKey(tokenKey) as? String
            }
            set {
                userDefaults.setObject(newValue, forKey: tokenKey)
            }
        }

    }
    
    static let UUID = "com.xspyhack.History.UUID"
    
    static let perPage: Int = 30
    
    static let navigationBarWithoutStatusBarHeight: CGFloat = 44.0
    static let tabBarHeight: CGFloat = 44.0
    static let rowHeight: CGFloat = 48.0
    
    static let presentedViewControllerHeight: CGFloat = 440.0
    
    static let statusBarHeight: CGFloat = 20.0
    
    static let forcedHideActivityIndicatorTimeInterval: NSTimeInterval = 60.0
    
    static var textAttributes: TextAttributes = {
        return TextAttributes()
            .font(UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium))
            .lineSpacing(6.0)
            .alignment(.Left)
            .foregroundColor(.blackColor())
    }()
    
    static var TellerRecordName: String {
        get {
            return userDefaults.objectForKey("com.xspyhack.Histroy.TellerRecordName") as? String ?? "_2a8756cfa0c606aa6f49c5532ad6a935"
        }
        set {
            userDefaults.setObject(newValue, forKey: "com.xspyhack.Histroy.TellerRecordName")
        }
    }
}

extension UIColor {
    static func tintColor() -> UIColor {
        return UIColor(hex: Defaults.Color.tintColor)
    }
}

class Wrapper<T> {
    let candy: T
    
    init(bullet: T) {
        self.candy = bullet
    }
}

struct DispatchAsyncQueue {
    
    static func Main(block: dispatch_block_t) {
        dispatch_async(dispatch_get_main_queue()) { 
            block()
        }
    }
    
    static func Default(block: dispatch_block_t) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            block()
        }
    }
}