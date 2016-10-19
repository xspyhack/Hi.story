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
        case .none: return "#000000"
        }
    }
    
    public static var count: Int {
        return Tag.fuschia.rawValue + 1
    }
    
    public static var tags: [Tag] {
        return [.red, .blue, .orange, .yellow, .green, .gray, .fuschia]
    }
}

public struct SharedMatter {
    
    public let id: String
    
    public let createdAt: TimeInterval
    public let updatedAt: TimeInterval
    
    public let title: String
    public let body: String
    public let happenedAt: TimeInterval
    
    public let kind: Int
    
    public let tag: Int
}
