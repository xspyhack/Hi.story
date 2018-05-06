//
//  Memory.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 06/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Hikit

public enum MemoryContent {
    case text(String)
    case photo(Photo)
    case video(URL)
    case audio(URL)
}

public protocol Memory {
    
    var date: Date { get }
    
    var content: MemoryContent { get }
}

public struct AnyMemory {
    
    let date: Date
    
    let content: MemoryContent
    
    init(date: Date, content: MemoryContent) {
        self.date = date
        self.content = content
    }
}

/**
protocol Memory {
    
    associatedtype Content
    
    var date: Date { get }
    
    var content: Content { get }
}

struct AnyMemory<Content>: Memory {
    
    var date: Date
    
    var content: Content
    
    init<M: Memory>(_ memory: M) where M.Content == Content {
        self.date = memory.date
        self.content = memory.content
    }
}
 */
