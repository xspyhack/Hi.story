//
//  MemoriesViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 06/04/2018.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation
import RxSwift

public struct MemoriesViewModel {

    public var memories: [Memory]
    
    public var count: Int {
        return memories.count
    }
    
    public var index: Variable<Int> = Variable(0)
    
    public var animating: Bool = false
    
    public init(texts: [Text] = [], photos: [Photograph] = [], videos: [Video] = []) {
        self.memories = (texts as [Memory]) + (photos as [Memory]) + (videos as [Memory])
    }
    
    public init(memories: [Memory]) {
        self.memories = memories
    }
    
    func validatedIndex(_ index: Int) -> Bool {
        return index >= 0 && index < self.count
    }
}
