//
//  Matter.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

import RealmSwift

public enum MatterKind: Int {
    case Past
    case Coming
}

public class Matter: Object {
    
    public dynamic var matterID: String = ""
    
    public dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    public dynamic var updatedUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    public dynamic var creator: User?
    public dynamic var title: String = ""
    public dynamic var body: String = ""
    
    public dynamic var kind: Int = MatterKind.Coming.rawValue
    public dynamic var location: Location?
    
    public dynamic var tag: String = "" // MAYBE COLOR

    public dynamic var story: Story? //  关联的 Story，在删除的时候需要注意，cascade delete
}