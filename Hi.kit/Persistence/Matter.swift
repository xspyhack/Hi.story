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

// [K]: https://en.wikipedia.org/wiki/K_(anime)
// [Kings]: https://en.wikipedia.org/wiki/List_of_K_characters

public enum Tag: Int {
    case White = 1
    case Yellow
    case Red
    case Blue
    case Green
    case Gray
    case None
    case LightBlue
    case Orange
    case Fuschia
    
    public var name: String {
        switch self {
        case .Red: return "Mikoto Suoh"
        case .Blue: return "Reisi Munakata"
        case .Yellow: return "Daikaku Kokujoji"
        case .Green: return "Nagare Hisui"
        case .Gray: return "Tenkei Iwahune"
        case .None: return "Colorless King"
        case .White: return "Adolf·K·Weismann"
        case .LightBlue: return "Light Blue"
        case .Orange: return "Orange"
        case .Fuschia: return "Fuschia"
        }
    }
    
    public var value: String {
        switch self {
        case .Red: return "#FE3824"
        case .Green: return "#44DB5E"
        case .LightBlue: return "#54C7FC"
        case .Yellow: return "#FFCD00"
        case .Orange: return "#FF9600"
        case .Fuschia: return "#FE2851"
        case .Blue: return "#0076FF"
        case .Gray: return "#A4AAB3"
        case .White: return "#FFFFFF"
        case .None: return "#"
        }
    }
    
    public static var count: Int {
        return Tag.Fuschia.rawValue + 1
    }
    
    public static var tags: [Tag] {
        return [.Red, .Blue, .Orange, .Yellow, .Green, .Gray, .Fuschia]
    }
}

public class Matter: Object {
    
    public dynamic var matterID: String = NSUUID().UUIDString
    
    public dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    public dynamic var updatedUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    public dynamic var creator: User?
    public dynamic var title: String = ""
    public dynamic var body: String = ""
    public dynamic var happenedUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    public dynamic var kind: Int = MatterKind.Coming.rawValue
    public dynamic var location: Location?
    
    public dynamic var tag: Int = Tag.None.rawValue // MAYBE COLOR

    public dynamic var story: Story? //  关联的 Story，在删除的时候需要注意，cascade delete
}