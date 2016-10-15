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
    case plainText
    case image
    case audio
    case rich
}

public enum Visible: Int {
    case `public` = 0
    case `private`
}

public class Story: Object {
    
    public dynamic var id: String = ""
    public dynamic var allowComment: Bool = true
    
    public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    public dynamic var updatedAt: TimeInterval = Date().timeIntervalSince1970
    
    //public dynamic var creator: User?
    public dynamic var title: String = ""
    public dynamic var body: String = ""
    
    public dynamic var attachment: Attachment?
    
    public dynamic var kind: String = StoryKind.plainText.rawValue
    public dynamic var location: Location?
    
    public dynamic var tag: String? = ""
    
    public override class func indexedProperties() -> [String] {
        return ["id"]
    }
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
        return realm.objects(Story.self).sorted(byProperty: "createdAt", ascending: true).flatMap { $0 }
    }
    
    open func fetchLatest(fromRealm realm: Realm) -> Story? {
        return realm.objects(Story.self).sorted(byProperty: "updatedAt", ascending: false).flatMap { $0 }.first
    }
}
