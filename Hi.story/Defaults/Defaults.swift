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
        
        // Settings
        
        static let notificationsEnabled = prefix + "notificationsEnabled"
        static let backgroundModeEnabled = prefix + "backgroundModeEnabled"
        
        static let birthday = prefix + "birthday"
        static let connectPhotos = prefix + "connectPhotos"
        static let connectReminders = prefix + "connectReminders"
        static let connectCalendar = prefix + "connectCalendar"
        
        // Labs
        static let spotlightEnabled = prefix + "spotlightEnabled"
        static let handoffEnabled = prefix + "handoffEnabled"
        static let siriEnabled = prefix + "siriEnabled"
        
        static let latestAnalyingDate = prefix + "latestAnalyingDate"
        
        static let hadInitializeBackgroundMode = prefix + "hadInitializeBackgroundMode"
    }
    

    
    static let navigationBarWithoutStatusBarHeight: CGFloat = 44.0
    static let tabBarHeight: CGFloat = 44.0
    static let rowHeight: CGFloat = 48.0
    
    static let presentedViewControllerHeight: CGFloat = 440.0
    
    static let statusBarHeight: CGFloat = 20.0
    
    static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 60.0
    
    static let feedsMaxContentHeight: CGFloat = 68.0
    static let storiesMaxContentHeight: CGFloat = 68.0
    
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
    
    static var connectPhotos: Bool {
        get {
            return userDefaults.bool(forKey: Key.connectPhotos)
        }
        set {
            userDefaults.set(newValue, forKey: Key.connectPhotos)
        }
    }
    
    static var connectCalendar: Bool {
        get {
            return userDefaults.bool(forKey: Key.connectCalendar)
        }
        set {
            userDefaults.set(newValue, forKey: Key.connectCalendar)
        }
    }
    
    static var connectReminders: Bool {
        get {
            return userDefaults.bool(forKey: Key.connectReminders)
        }
        set {
            userDefaults.set(newValue, forKey: Key.connectReminders)
        }
    }
    
    static var notificationsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Key.notificationsEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Key.notificationsEnabled)
        }
    }
    
    static var backgroundModeEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Key.backgroundModeEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Key.backgroundModeEnabled)
        }
    }

    static var birthday: TimeInterval? {
        get {
            return userDefaults.value(forKey: Key.birthday) as? TimeInterval
        }
        set {
            userDefaults.set(newValue, forKey: Key.birthday)
        }
    }
    
    static var spotlightEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Key.spotlightEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Key.spotlightEnabled)
        }
    }
    
    static var handoffEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Key.handoffEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Key.handoffEnabled)
        }
    }
    
    static var siriEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Key.siriEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Key.siriEnabled)
        }
    }
    
    static var latestAnalyingDate: String {
        get {
            return userDefaults.string(forKey: Key.latestAnalyingDate) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: Key.latestAnalyingDate)
        }
    }
    
    static var hadInitializeBackgroundMode: Bool {
        get {
            return userDefaults.bool(forKey: Key.hadInitializeBackgroundMode)
        }
        set {
            userDefaults.set(newValue, forKey: Key.hadInitializeBackgroundMode)
        }
    }
}

class Wrapper<T> {
    let candy: T
    
    init(bullet: T) {
        self.candy = bullet
    }
}
