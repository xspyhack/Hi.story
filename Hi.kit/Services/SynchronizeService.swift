//
//  SynchronizeService.swift
//  Hi.kit
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
            realm.add(resource, update: true)
        }
    }
    
    public func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> T? {
        return realm.objects(T.self).filter(predicate).first
    }
    
    public func fetch(withPredicate predicate: NSPredicate, fromRealm realm: Realm) -> T? {
        return realm.objects(T.self).filter(predicate).first
    }
    
    public func fetchAll(sortby property: String? = nil, fromRealm realm: Realm) -> [T] {
        if let property = property {
            return realm.objects(T.self).sorted(byKeyPath: property, ascending: false).compactMap { $0 }
        } else {
            return realm.objects(T.self).compactMap { $0 }
        }
    }
    
    public func fetchAll(withPredicate predicate: NSPredicate, fromRealm realm: Realm) -> [T] {
        return realm.objects(T.self).filter(predicate).sorted(byKeyPath: "createdAt", ascending: true).compactMap { $0 }
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

