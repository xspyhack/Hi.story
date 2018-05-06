//
//  Matter.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public class Matter: Object, Timetable {
    
    @objc public dynamic var id: String = UUID().uuidString
    
    @objc public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    @objc public dynamic var updatedAt: TimeInterval = Date().timeIntervalSince1970
   
    @objc public dynamic var creator: User?
    @objc public dynamic var title: String = ""
    @objc public dynamic var body: String = ""
    @objc public dynamic var happenedAt: TimeInterval = Date().timeIntervalSince1970
    
    @objc public dynamic var kind: Int = MatterKind.coming.rawValue
    @objc public dynamic var location: Location?
    
    @objc public dynamic var tag: Int = Tag.none.rawValue // MAYBE COLOR

    @objc public dynamic var story: Story? //  关联的 Story，在删除的时候需要注意，cascade delete
    
    public func cascadeDelete(inRealm realm: Realm) {
        
        if let location = location {
            if let coordinate = location.coordinate {
                realm.delete(coordinate)
            }
            realm.delete(location)
        }
    }
   
    // Timetable
    // 应该根据 happenedAt，而不是 createdAt
    public var monthDay: String {
        return Date(timeIntervalSince1970: happenedAt).hi.monthDay
    }
    
    public var year: String {
        return Date(timeIntervalSince1970: happenedAt).hi.year
    }
}

open class MatterService: Synchronizable {
    
    public typealias T = Matter
    
    open static let shared = MatterService()
    
    open func synchronize(_ resource: Matter, toRealm realm: Realm) {
        
        let _ = try? realm.write {
            realm.add(resource)
        }
    }
}

extension Matter {
    
    public static func shared(with matter: Matter) -> SharedMatter {
        return SharedMatter(id: matter.id, createdAt: matter.createdAt, updatedAt: matter.updatedAt, title: matter.title, body: matter.body, happenedAt: matter.happenedAt, kind: matter.kind, tag: matter.tag)
    }
    
    public static func from(_ shared: SharedMatter) -> Matter {
        let matter = Matter()
        matter.id = shared.id
        matter.createdAt = shared.createdAt
        matter.updatedAt = shared.updatedAt
        matter.title = shared.title
        matter.body = shared.body
        matter.happenedAt = shared.happenedAt
        matter.kind = shared.kind
        matter.tag = shared.tag
        return matter
    }
}


