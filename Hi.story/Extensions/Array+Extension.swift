//
//  Array+Extension.swift
//  Dribbbiu
//
//  Created by bl4ckra1sond3tre on 4/27/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : .none
    }
}
