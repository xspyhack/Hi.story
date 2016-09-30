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
            return realm.objects(T.self).sorted(byProperty: property, ascending: true).flatMap { $0 }
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

public class StoryService: Synchronizable {
    
    public typealias T = Story
    open static let shared = StoryService()
    
    open func synchronize(_ resource: Story, toRealm realm: Realm) {
    
        let _ = try? realm.write {
            print("add")
            realm.add(resource)
        }
    }
    
    open func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> Story? {
        return realm.objects(Story.self).filter(predicate).first
    }
    
    open func fetchAll(fromRealm realm: Realm) -> [Story] {
        return realm.objects(Story.self).sorted(byProperty: "createdUnixTime", ascending: true).flatMap { $0 }
    }
    
    open func fetchLatest(fromRealm realm: Realm) -> Story? {
        return realm.objects(Story.self).sorted(byProperty: "updatedUnixTime", ascending: false).flatMap { $0 }.first
    }
}

public class MatterService: Synchronizable {
    
    public typealias T = Matter
    
    open static let shared = MatterService()
    
    open func fetchAll(fromRealm realm: Realm) -> [T] {
        return realm.objects(Matter.self).sorted(byProperty: "createdUnixTime", ascending: true).flatMap { $0 }
    }
}
