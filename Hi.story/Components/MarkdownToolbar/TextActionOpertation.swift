//
//  TextActionOpertation.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 22/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

// For bottom toolbar action
struct TextActionOperation {
    
    enum Operation {
        case line(String)
        case wrap(String, String)
        case execute(() -> Void)
        case multi([Operation])
    }
    
    let icon: UIImage?
    let operation: Operation
    let name: String
}
