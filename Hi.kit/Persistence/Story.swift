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

open class Story: Object {
    
    open dynamic var storyID: String = ""
    open dynamic var allowComment: Bool = true
    
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var creator: User?
    open dynamic var title: String = ""
    open dynamic var body: String = ""
    
    open dynamic var attachment: Attachment?
    
    open dynamic var kind: String = StoryKind.plainText.rawValue
    open dynamic var location: Location?
    
    open dynamic var tag: String? = ""
    
    open dynamic var likesCount: Int = 0
    open dynamic var visible: Int = Visible.public.rawValue
    
    open override class func indexedProperties() -> [String] {
        return ["storyID"]
    }
}
