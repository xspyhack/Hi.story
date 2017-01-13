//
//  Refreshable.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/4/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol Refreshable {
    
    var isAtTop: Bool { get }
    
    func refresh()
    
    func scrollsToTopIfNeeded()
}

extension Refreshable {
    
    func scrollsToTopIfNeeded() {
    }
}
