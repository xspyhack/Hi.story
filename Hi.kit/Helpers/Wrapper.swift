//
//  Wrapper.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 14/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

/// 糖衣炮弹
public class Wrapper<T> {
    public let candy: T
    
    public init(bullet: T) {
        self.candy = bullet
    }
}
