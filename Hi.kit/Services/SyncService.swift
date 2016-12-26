//
//  SyncService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/3/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Synchronizable {
    
    associatedtype T
    func synchronize(_ resource: T, toRealm realm: Realm)
    
    func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> T?
    
    func fetchAll(sortby property: String?, fromRealm realm: Realm) -> [T]
    
    func remove(_ resource: T, fromRealm realm: Realm)
}

extension Synchronizable where T: Object {
    
    // Save
    
    public func synchronize(_ resource: T, toRealm realm: Realm) {
        
        let _ = try? realm.write {
            print("add")
            realm.add(resource)
        }
    }
    
    public func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> T? {
        return realm.objects(T.self).filter(predicate).first
    }
    
    public func fetchAll(sortby property: String? = nil, fromRealm realm: Realm) -> [T] {
        if let property = property {
            return realm.objects(T.self).sorted(byProperty: property, ascending: false).flatMap { $0 }
        } else {
            return realm.objects(T.self).flatMap { $0 }
        }
    }
    
    // Delete
    
    public func remove(_ resource: T, fromRealm realm: Realm) {
        
        let _ = try? realm.write {
            realm.delete(resource)
        }
    }
}

public struct Promise {
    
    let predicate: NSPredicate
}

