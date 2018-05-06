//
//  Object.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

class Wrapper<T> {
    let candy: T
    
    init(bullet: T) {
        self.candy = bullet
    }
}
