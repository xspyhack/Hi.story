//
//  Feed.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 5/31/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RealmSwift

public class Feed: Object, Timetable {
    @objc public dynamic var id: String = UUID().uuidString
    @objc public dynamic var story: Story?
    @objc public dynamic var creator: User?
    @objc public dynamic var likesCount: Int = 0
    @objc public dynamic var visible: Int = Visible.public.rawValue
    @objc public dynamic var createdAt: TimeInterval = Date().timeIntervalSince1970
    
    public override class func primaryKey() -> String? {
        return "id"
    }
}

open class FeedService: Synchronizable {
    
    public typealias T = Feed
    
    open static let shared = FeedService()
}
