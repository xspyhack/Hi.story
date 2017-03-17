//
//  Covers.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 17/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

enum King: Int {
    case adolf
    case kokujoji
    case suoh
    case munakata
    case tenkei
    case hisui
    case misyakuji
    case goRA
    
    var name: String {
        switch self {
        case .adolf: return "Adolf·K·Weismann"
        case .kokujoji: return "Kokujoji Daikaku"
        case .suoh: return "Suoh Mikoto"
        case .munakata: return "Munakata Reisi"
        case .tenkei: return "Tenkei Iwahune"
        case .hisui: return "Hisui Nagare"
        case .misyakuji: return "Misyakuji Yukari"
        case .goRA: return "GoRA"
        }
    }
    
    var card: UIImage? {
        switch self {
        case .adolf: return UIImage.hi.adolf
        case .kokujoji: return UIImage.hi.kokujoji
        case .suoh: return UIImage.hi.suoh
        case .munakata: return UIImage.hi.munakata
        case .tenkei: return UIImage.hi.tenkei
        case .hisui: return UIImage.hi.hisui
        case .misyakuji: return UIImage.hi.misyakuji
        case .goRA: return UIImage.hi.goRA
        }
    }
    
    static var all: [King] = [
        .adolf, .kokujoji, .suoh, .munakata, .tenkei, .hisui, .misyakuji, .goRA
    ]
}
