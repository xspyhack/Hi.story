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
    func synchronize(resource: T, toRealm realm: Realm)
    
    func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> T?
    
    func fetchAll(sortby property: String?, fromRealm realm: Realm) -> [T]
}

extension Synchronizable where T: Object {
    
    public func synchronize(resource: T, toRealm realm: Realm) {
        
        let _ = try? realm.write {
            print("add")
            realm.add(resource)
        }
    }
    
    public func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> T? {
        return realm.objects(T).filter(predicate).first
    }
    
    public func fetchAll(sortby property: String? = nil, fromRealm realm: Realm) -> [T] {
        return realm.objects(T).flatMap { $0 }
    }
}

public struct Promise {
    
    let predicate: NSPredicate
}

public class StoryService: Synchronizable {
    
    public typealias T = Story
    public static let sharedService = StoryService()
    
    public func synchronize(resource: Story, toRealm realm: Realm) {
    
        let _ = try? realm.write {
            print("add")
            realm.add(resource)
        }
    }
    
    public func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> Story? {
        return realm.objects(Story).filter(predicate).first
    }
    
    public func fetchAll(fromRealm realm: Realm) -> [Story] {
        return realm.objects(Story).sorted("createdUnixTime", ascending: true).flatMap { $0 }
    }
    
    public func fetchLatest(fromRealm realm: Realm) -> Story? {
        return realm.objects(Story).sorted("updatedUnixTime", ascending: false).flatMap { $0 }.first
    }
}

public class MatterService: Synchronizable {
    
    public typealias T = Matter
    
    public static let sharedService = MatterService()
    
    public func fetchAll(fromRealm realm: Realm) -> [T] {
        return realm.objects(Matter).sorted("updatedUnixTime", ascending: true).flatMap { $0 }
    }
}
