//
//  UserDefaults.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public struct HiUserDefaults {
    
    private static let userDefaults = Foundation.UserDefaults(suiteName: Configure.appGroupIdentifier)!

    private struct Key {
        static let prefix = "com.xspyhack.History."
        
        static let userID = prefix + "userID"
        static let nickname = prefix + "nickname"
        static let bio = prefix + "bio"
        static let avatar = prefix + "avatar"
    }
    
    public static var userID: Listenable<String?> = {
        let userID = userDefaults.string(forKey: Key.userID)
        
        return Listenable<String?>(userID) { userID in
            userDefaults.set(userID, forKey: Key.userID)
        }
    }()
    
    public static var nickname: Listenable<String?> = {
        let nickname = userDefaults.string(forKey: Key.nickname)
        
        return Listenable<String?>(nickname) { nickname in
            userDefaults.set(nickname, forKey: Key.nickname)
            
            guard let realm = try? Realm() else { return }
            
            if let nickname = nickname, let god = Service.god(of: realm) {
                let _ = try? realm.write {
                    god.nickname = nickname
                }
            }
        }
    }()
    
    public static var bio: Listenable<String?> = {
        let bio = userDefaults.string(forKey: Key.bio)
        
        return Listenable<String?>(bio) { bio in
            userDefaults.set(bio, forKey: Key.bio)
            
            guard let realm = try? Realm() else { return }
            
            if let bio = bio, let god = Service.god(of: realm) {
                let _ = try? realm.write {
                    god.bio = bio
                }
            }
        }
    }()
    
    public static var avatar: Listenable<String?> = {
        let avatar = userDefaults.string(forKey: Key.avatar)
        
        return Listenable<String?>(avatar) { avatar in
            userDefaults.set(avatar, forKey: Key.avatar)
            
            guard let realm = try? Realm() else { return }
            
            if let avatar = avatar, let god = Service.god(of: realm) {
                let _ = try? realm.write {
                    god.avatarURLString = avatar
                }
            }
        }
    }()
}
