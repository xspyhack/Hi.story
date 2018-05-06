//
//  Photograph.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 06/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit

public struct Photograph: Memory {
    
    public let date: Date
    
    public let content: MemoryContent
    
    public init(date: Date, content: Photo) {
        self.date = date
        self.content = .photo(content)
    }
}
