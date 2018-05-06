//
//  Service.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public typealias JSONDictionary = [String: Any]

public protocol Serializable {
    init?(json: JSONDictionary)
}

public struct Service {
    
    public static func god(of realm: Realm) -> User? {
        guard let userID = HiUserDefaults.userID.value else { return nil }
        
        let predicate = NSPredicate(format: "id = %@", userID)
        
        #if DEBUG
            let users = realm.objects(User.self).filter(predicate)
            if users.count > 1 {
                print("Warning: same user id: \(users.count), \(userID)")
            }
        #endif
        
        return realm.objects(User.self).filter(predicate).first
    }
    
    public static var god: User? {
        guard let realm = try? Realm() else { return nil }
        
        return god(of: realm)
    }
}
