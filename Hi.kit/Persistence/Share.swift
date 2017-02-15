//
//  Share.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

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
    case purple
    case hi
    
    public var name: String {
        switch self {
        case .red: return "Suoh Mikoto"
        case .blue: return "Munakata Reisi"
        case .yellow: return "Kokujoji Daikaku"
        case .green: return "Hisui Nagare"
        case .gray: return "Tenkei Iwahune"
        case .none: return "King Colorless"
        case .white: return "Adolf·K·Weismann"
        case .purple: return "Misyakuji Yukari" // Purple
        case .lightBlue: return "Light Blue"
        case .orange: return "Orange"
        case .hi: return "Hi"
        }
    }
    
    public var value: String {
        switch self {
        case .red: return "#C01329"
        case .blue: return "#1270B5"
        case .yellow: return "#A38A4B"
        case .green: return "#176538"
        case .gray: return "#64605F"
        case .none: return "#000000"
        case .white: return "#FFFFFF"
        case .purple: return "#D427E3"
        case .lightBlue: return "#54C7FC"
        case .orange: return "#FF9600"
        case .hi: return "#1BBBBB"
        }
    }
    
    public static var count: Int {
        return Tag.hi.rawValue + 1
    }
    
    public static var tags: [Tag] {
        return [.red, .blue, .orange, .yellow, .green, .gray, .purple]
    }
    
    public static func random(exceptBit: Bool = true) -> Tag {
        if exceptBit {
            return randomExceptBit()
        } else {
            return Tag(rawValue: Int(arc4random_uniform(UInt32(Tag.count)))) ?? .none
        }
    }
    
    public static func randomExceptBit() -> Tag {
        var tag: Tag
        repeat {
            tag = Tag.random(exceptBit: false)
        } while (tag == .none || tag == .white)
       
        return tag
    }
    
    public static func with(_ integer: Int) -> Tag {
        let a = integer % count + 2
        let tag = Tag(rawValue: a) ?? .hi
        return tag == .white || tag == .none ? .hi : tag
    }
}

public struct SharedUser: Hashable {
    public let id: String
    public let username: String
    public let nickname: String
    public let bio: String?
    public let avatarURLString: String?
    
    public let createdAt: TimeInterval
    public let lastSignInAt: TimeInterval
    
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func user(with user: User) -> SharedUser {
        return SharedUser(id: user.id, username: user.username, nickname: user.nickname, bio: user.bio, avatarURLString: user.avatarURLString, createdAt: user.createdAt, lastSignInAt: user.lastSignInAt)
    }
}

public func ==(lhs: SharedUser, rhs: SharedUser) -> Bool {
    return lhs.id == rhs.id
}

public struct SharedMatter: Hashable {
    
    public let id: String
    
    public let createdAt: TimeInterval
    public let updatedAt: TimeInterval
    
    public let title: String
    public let body: String
    public let happenedAt: TimeInterval
    
    public let kind: Int
    
    public let tag: Int
    
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func matter(with matter: Matter) -> SharedMatter {
        return SharedMatter(id: matter.id, createdAt: matter.createdAt, updatedAt: matter.updatedAt, title: matter.title, body: matter.body, happenedAt: matter.happenedAt, kind: matter.kind, tag: matter.tag)
    }
}

public func ==(lhs: SharedMatter, rhs: SharedMatter) -> Bool {
    return lhs.id == rhs.id
}

public struct SharedFeed: Hashable {
   
    public let id: String
    
    public var hashValue: Int {
        return id.hashValue
    }
}

public func ==(lhs: SharedFeed, rhs: SharedFeed) -> Bool {
    return lhs.id == rhs.id
}
