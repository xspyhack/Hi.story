//
//  Text.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 06/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public struct Text: Memory {
    
    public let date: Date
    
    public let content: MemoryContent
    
    public init(date: Date, content: String) {
        self.date = date
        self.content = .text(content)
    }
}
