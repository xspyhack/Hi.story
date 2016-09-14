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
    case single(Date)
    case range(Int, Int)
    case all
}

struct StorysViewModel {
    
    var storyViewModels: [StoryViewModel] = []
    
    var type: StoryFetchType = .all
    
    let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    mutating func fetchStorys() {
        var params = [
            "uuid": UUID.uuid
        ]
        switch type {
        case .single(let date):
            params["date"] = date.hi.yearMonthDay
        case .range(let from, let to):
            params["from"] = "\(from)"
            params["to"] = "\(to)"
        case .all:
            break
        }
        fetch(parameters: params)
    }
    
    fileprivate mutating func fetch(parameters params: JSONDictionary) {
        
    }
}
