//
//  UserDefaults.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

fileprivate let userIDKey = "userID"
fileprivate let nicknameKey = "nickname"
fileprivate let bioKey = "bio"

public struct UserDefaults {
    
    private static let userDefaults = Foundation.UserDefaults(suiteName: Configure.appGroupIdentifier)!

    static let prefix = "com.xspyhack.History."
    public static func set<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: prefix + key)
    }
    
    public static func value(forKey key: String) -> Any? {
        return userDefaults.value(forKey: prefix + key)
    }
    
    public static func value<T>(forKey key: String) -> T {
        return userDefaults.value(forKey: prefix + key) as! T
    }
    
    public static var userID: Listenable<String?> = {
        let userID: String? = value(forKey: userIDKey)
        
        return Listenable<String?>(userID) { userID in
            set(userID, forKey: userIDKey)
        }
    }()
    
    public static var nickname: Listenable<String?> = {
        let nickname: String? = value(forKey: nicknameKey)
        
        return Listenable<String?>(nickname) { nickname in
            set(nickname, forKey: nicknameKey)
            
            guard let realm = try? Realm() else { return }
            
            if let nickname = nickname, let god = Service.god(of: realm) {
                let _ = try? realm.write {
                    god.nickname = nickname
                }
            }
        }
    }()
    
    public static var bio: Listenable<String?> = {
        let bio: String? = value(forKey: bioKey)
        
        return Listenable<String?>(bio) { bio in
            set(bio, forKey: bioKey)
            
            guard let realm = try? Realm() else { return }
            
            if let bio = bio, let god = Service.god(of: realm) {
                let _ = try? realm.write {
                    god.bio = bio
                }
            }
        }
    }()
}
