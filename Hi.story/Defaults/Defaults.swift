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
    
    struct Color {
        static let tint = "#1BBBBB"
        static let from = "#1EEEEE"
        static let to = "#133333"
        static let border = "#EEEEEE"
        static let separator = "#DDDDDD"
        static let text = "#353535"
        static let placeholder = "#C7C7C7"
    }
    
    struct Authentication {
        static let tokenKey = "History.Authentication.Token"
        static var token: String? {
            get {
                return userDefaults.object(forKey: tokenKey) as? String
            }
            set {
                userDefaults.set(newValue, forKey: tokenKey)
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
    
    static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 60.0
    
    /*
    static var textAttributes: TextAttributes = {
        return TextAttributes()
            .font(UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium))
            .lineSpacing(6.0)
            .alignment(.left)
            .foregroundColor(.black())
    }()*/
    
    static var TellerRecordName: String {
        get {
            return userDefaults.object(forKey: "com.xspyhack.Histroy.TellerRecordName") as? String ?? "_2a8756cfa0c606aa6f49c5532ad6a935"
        }
        set {
            userDefaults.set(newValue, forKey: "com.xspyhack.Histroy.TellerRecordName")
        }
    }
}

class Wrapper<T> {
    let candy: T
    
    init(bullet: T) {
        self.candy = bullet
    }
}
