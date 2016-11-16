//
//  Matter.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public class Matter: Object {
    
    public dynamic var id: String = UUID().uuidString
    
    public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    public dynamic var updatedAt: TimeInterval = Date().timeIntervalSince1970
    
    public dynamic var creator: User?
    public dynamic var title: String = ""
    public dynamic var body: String = ""
    public dynamic var happenedAt: TimeInterval = Date().timeIntervalSince1970
    
    public dynamic var kind: Int = MatterKind.coming.rawValue
    public dynamic var location: Location?
    
    public dynamic var tag: Int = Tag.none.rawValue // MAYBE COLOR

    public dynamic var story: Story? //  关联的 Story，在删除的时候需要注意，cascade delete
    
    public func cascadeDelete(inRealm realm: Realm) {
        
        if let location = location {
            if let coordinate = location.coordinate {
                realm.delete(coordinate)
            }
            realm.delete(location)
        }
    }
}

public class MatterService: Synchronizable {
    
    public typealias T = Matter
    
    open static let shared = MatterService()
    
    open func fetchAll(fromRealm realm: Realm) -> [T] {
        return realm.objects(Matter.self).sorted(byProperty: "createdAt", ascending: true).flatMap { $0 }
    }
}


