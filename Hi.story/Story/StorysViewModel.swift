//
//  StorysViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/21/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

enum StoryFetchType {
    case Single(NSDate)
    case Range(Int, Int)
    case All
}

struct StorysViewModel {
    
    var storyViewModels: [StoryViewModel] = []
    
    var type: StoryFetchType = .All
    
    let completion: () -> Void
    
    init(completion: () -> Void) {
        self.completion = completion
    }
    
    mutating func fetchStorys() {
        var params = [
            "uuid": UUID.uuid
        ]
        switch type {
        case .Single(let date):
            params["date"] = date.xh_yearMonthDay
        case .Range(let from, let to):
            params["from"] = "\(from)"
            params["to"] = "\(to)"
        case .All:
            break
        }
        fetch(parameters: params)
    }
    
    private mutating func fetch(parameters params: JSONDictionary) {
        
    }
}