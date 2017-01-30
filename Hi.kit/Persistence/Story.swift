//
//  Story.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public enum StoryKind: String {
    case plain
    case image
    case audio
    case rich
}

public enum Visible: Int {
    case `public` = 0
    case `private`
}

public class Story: Object {
    
    public dynamic var id: String = UUID().uuidString
    public dynamic var allowComment: Bool = true
    
    public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    public dynamic var updatedAt: TimeInterval = Date().timeIntervalSince1970
    
    // For query
    public var monthDay: String {
        return Date(timeIntervalSince1970: createdAt).hi.monthDay
    }
    public var year: String {
        return Date(timeIntervalSince1970: createdAt).hi.year
    }
    
    //public dynamic var creator: User?
    public dynamic var title: String = ""
    public dynamic var body: String = ""
    
    public dynamic var attachment: Attachment?
    
    public dynamic var kind: String = StoryKind.plain.rawValue
    public dynamic var location: Location?
    
    public dynamic var withStorybook: Storybook?
    
    public dynamic var tag: String? = ""
    
    public dynamic var isPublished: Bool = false
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public override class func indexedProperties() -> [String] {
        return ["id"]
    }
    
    public func cascadeDelete(inRealm realm: Realm) {
        
        if let attachment = attachment {
            realm.delete(attachment)
        }
        
        if let location = location {
            if let coordinate = location.coordinate {
                realm.delete(coordinate)
            }
            realm.delete(location)
        }
    }
}

open class StoryService: Synchronizable {
    
    public typealias T = Story
    open static let shared = StoryService()
    
    open func unpublished(fromRealm realm: Realm) -> [Story] {
        return realm.objects(Story.self).filter("isPublished = false").sorted(byKeyPath: "createdAt", ascending: false).flatMap { $0 }
    }
    
    open func fetch(withPredicate predicate: String, fromRealm realm: Realm) -> Story? {
        return realm.objects(Story.self).filter(predicate).first
    }
    
    open func fetchAll(fromRealm realm: Realm) -> [Story] {
        return realm.objects(Story.self).sorted(byKeyPath: "createdAt", ascending: true).flatMap { $0 }
    }
    
    open func fetchLatest(fromRealm realm: Realm) -> Story? {
        return realm.objects(Story.self).sorted(byKeyPath: "updatedAt", ascending: false).flatMap { $0 }.first
    }
}
