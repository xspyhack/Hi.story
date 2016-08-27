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
    case PlainText
    case Image
    case Audio
    case Rich
}

public enum Visible: Int {
    case Public = 0
    case Private
}

public class Story: Object {
    
    public dynamic var storyID: String = ""
    public dynamic var allowComment: Bool = true
    
    public dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    public dynamic var updatedUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    public dynamic var creator: User?
    public dynamic var title: String = ""
    public dynamic var body: String = ""
    
    public dynamic var attachment: Attachment?
    
    public dynamic var kind: String = StoryKind.PlainText.rawValue
    public dynamic var location: Location?
    
    public dynamic var tag: String? = ""
    
    public dynamic var likesCount: Int = 0
    public dynamic var visible: Int = Visible.Public.rawValue
    
    public override class func indexedProperties() -> [String] {
        return ["storyID"]
    }
}
