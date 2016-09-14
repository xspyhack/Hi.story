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
    case past
    case coming
}

// [K]: https://en.wikipedia.org/wiki/K_(anime)
// [Kings]: https://en.wikipedia.org/wiki/List_of_K_characters

public enum Tag: Int {
    case white = 1
    case yellow
    case red
    case blue
    case green
    case gray
    case none
    case lightBlue
    case orange
    case fuschia
    
    public var name: String {
        switch self {
        case .red: return "Mikoto Suoh"
        case .blue: return "Reisi Munakata"
        case .yellow: return "Daikaku Kokujoji"
        case .green: return "Nagare Hisui"
        case .gray: return "Tenkei Iwahune"
        case .none: return "Colorless King"
        case .white: return "Adolf·K·Weismann"
        case .lightBlue: return "Light Blue"
        case .orange: return "Orange"
        case .fuschia: return "Fuschia"
        }
    }
    
    public var value: String {
        switch self {
        case .red: return "#FE3824"
        case .green: return "#44DB5E"
        case .lightBlue: return "#54C7FC"
        case .yellow: return "#FFCD00"
        case .orange: return "#FF9600"
        case .fuschia: return "#FE2851"
        case .blue: return "#0076FF"
        case .gray: return "#A4AAB3"
        case .white: return "#FFFFFF"
        case .none: return "#"
        }
    }
    
    public static var count: Int {
        return Tag.fuschia.rawValue + 1
    }
    
    public static var tags: [Tag] {
        return [.red, .blue, .orange, .yellow, .green, .gray, .fuschia]
    }
}

open class Matter: Object {
    
    open dynamic var matterID: String = UUID().uuidString
    
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var creator: User?
    open dynamic var title: String = ""
    open dynamic var body: String = ""
    open dynamic var happenedUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var kind: Int = MatterKind.coming.rawValue
    open dynamic var location: Location?
    
    open dynamic var tag: Int = Tag.none.rawValue // MAYBE COLOR

    open dynamic var story: Story? //  关联的 Story，在删除的时候需要注意，cascade delete
}
